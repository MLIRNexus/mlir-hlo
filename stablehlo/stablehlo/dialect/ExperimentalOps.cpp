/* Copyright 2023 The StableHLO Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include "stablehlo/dialect/ExperimentalOps.h"

#include <optional>

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/STLExtras.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypeInterfaces.h"
#include "mlir/IR/Types.h"

namespace mlir {
namespace stablehlo {

DynamicReduceWindowOpAdaptor::DynamicReduceWindowOpAdaptor(CustomCallOp op)
    : op_(op) {}

LogicalResult DynamicReduceWindowOpAdaptor::verify() {
  // Before checking the constraints inherited from ReduceWindowOp,
  // make sure that the operands and the attributes of the underlying custom
  // call make sense.
  if (op_->getNumOperands() != 2 * op_->getNumResults() + 5)
    return op_.emitError("expects size(operands) = 2 * size(results) + 5");
  if (op_->getNumResults() == 0)
    return op_.emitError("expects size(results) > 0");
  for (const auto& attr : op_->getAttrs()) {
    // api_version and backend_config have default values.
    // call_target_name should be "stablehlo.dynamic_reduce_window".
    // called_computations carries the body.
    if (attr.getName() != "api_version" &&
        attr.getName() != "backend_config" &&
        attr.getName() != "call_target_name" &&
        attr.getName() != "called_computations")
      return op_.emitError()
             << attr.getName() << " is not a supported attribute";
    if (!op_.getBackendConfig().empty())
      return op_.emitError() << "expects an empty backend_config";
  }

  // reduce_window_c1
  // This constraint hold automatically thanks to the checks that we have
  // performed above.
  auto numInputs = getInputs().size();

  // reduce_window_i1
  SmallVector<ShapedType> inputTypes;
  for (auto [index, input] : llvm::enumerate(getInputs())) {
    auto inputType = input.getType().dyn_cast<ShapedType>();
    inputTypes.push_back(inputType);
    if (!inputType)
      return op_.emitError()
             << "expects inputs (e.g. operand #" << index << ") to be tensors";
  }

  // reduce_window_i2
  SmallVector<ShapedType> initValueTypes;
  for (auto [index, initValue] : llvm::enumerate(getInitValues())) {
    auto initValueType = initValue.getType().dyn_cast<ShapedType>();
    initValueTypes.push_back(initValueType);
    if (!initValueType || !initValueType.hasRank() ||
        initValueType.getRank() != 0)
      return op_.emitError() << "expects init_values (e.g. operand #"
                             << numInputs + index << ") "
                             << "to be 0-dimensional tensors";
  }

  // reduce_window_i3...reduce_window_i7
  auto checkRank = [&](StringRef name, int64_t index, Value dynamicAttr,
                       int64_t expectedRank) -> LogicalResult {
    auto type = dynamicAttr.getType().dyn_cast<ShapedType>();
    if (!type || !type.hasRank() || type.getRank() != expectedRank ||
        !type.getElementType().isIntOrIndex()) {
      if (index < 0) index += op_->getNumOperands();
      return op_.emitError()
             << "expects " << name << " (operand #" << index << ") "
             << "to be a " << expectedRank << "-dimensional tensor "
             << "of integer or index type";
    }
    return success();
  };
  if (failed(checkRank("window_dimensions", -5, getWindowDimensions(), 1)) ||
      failed(checkRank("window_strides", -4, getWindowStrides(), 1)) ||
      failed(checkRank("base_dilations", -3, getBaseDilations(), 1)) ||
      failed(checkRank("window_dilations", -2, getWindowDilations(), 1)) ||
      failed(checkRank("padding", -1, getPadding(), 2)))
    return failure();

  // reduce_window_i7
  auto paddingType = getPadding().getType().dyn_cast<ShapedType>();
  if (!paddingType || !paddingType.hasRank() || paddingType.getRank() != 2 ||
      paddingType.getDimSize(1) != 2 ||
      !paddingType.getElementType().isIntOrIndex())
    return op_.emitError()
           << "expects padding_type (operand #" << op_.getNumOperands() - 1
           << ") to be a 2-dimensional tensor of integer or index type";

  // reduce_window_c2
  std::optional<ArrayRef<int64_t>> inputShape;
  for (auto inputType : inputTypes) {
    if (!inputType.hasRank()) continue;
    if (!inputShape) inputShape = inputType.getShape();
    if (inputType.getShape() != *inputShape)
      return op_.emitError() << "expects all inputs (operands 0.." << numInputs
                             << ") to have the same shape";
  }

  // reduce_window_c3
  for (auto [inputType, initValueType] :
       llvm::zip(inputTypes, initValueTypes)) {
    if (inputType.getElementType() != initValueType.getElementType())
      return op_.emitError() << "expects inputs (operands 0.." << numInputs
                             << ") and init_values (operands " << numInputs
                             << ".." << numInputs * 2 << ") to have pairwise "
                             << "the same element types";
  }

  // reduce_window_c4...reduce_window_c12
  // In this range, we only verify the constraints with even numbers.
  // Verifying the constraints with odd numbers would require knowing the
  // actual values of window_dimensions, window_strides, etc.
  // While we certainly can try to check whether they are constants and
  // verify them in that case, that seems like too much at this point.
  auto checkShape = [&](StringRef name, int64_t index, Value dynamicAttr,
                        ArrayRef<int64_t> expectedShape) -> LogicalResult {
    auto type = dynamicAttr.getType().cast<ShapedType>();
    if (type.getShape() != expectedShape) {
      if (index < 0) index += op_->getNumOperands();
      return op_.emitError()
             << "expects " << name << " (operand #" << index << ") "
             << "to be have shape [" << expectedShape << "]";
    }
    return success();
  };
  if (inputShape) {
    auto inputRank = static_cast<int64_t>(inputShape->size());
    if (failed(checkShape("window_dimensions", -5, getWindowDimensions(),
                          {inputRank})) ||
        failed(checkShape("window_strides", -4, getWindowStrides(),
                          {inputRank})) ||
        failed(checkShape("base_dilations", -3, getBaseDilations(),
                          {inputRank})) ||
        failed(checkShape("window_dilations", -2, getWindowDilations(),
                          {inputRank})) ||
        failed(checkShape("padding", -1, getPadding(), {inputRank, 2})))
      return failure();
  }

  // reduce_window_c13
  if (op_.getCalledComputations().size() != 1)
    return op_.emitError() << "expects called_computations to have 1 element";
  auto bodyAttr = op_.getCalledComputations()[0].cast<FlatSymbolRefAttr>();
  auto bodyFunc =
      op_->getParentOfType<ModuleOp>().lookupSymbol<func::FuncOp>(bodyAttr);
  if (!bodyFunc)
    return op_.emitError() << "expects called_computations to refer to "
                           << "a function that exists within a parent module";

  // reduce_window_c13
  SmallVector<Type> expectedBodyInputs;
  llvm::append_range(expectedBodyInputs, initValueTypes);
  llvm::append_range(expectedBodyInputs, initValueTypes);
  SmallVector<Type> expectedBodyOutputs;
  llvm::append_range(expectedBodyOutputs, initValueTypes);
  auto expectedBodyType = FunctionType::get(
      op_.getContext(), expectedBodyInputs, expectedBodyOutputs);
  if (bodyFunc.getFunctionType() != expectedBodyType)
    return op_.emitError() << "expects body to have type " << expectedBodyType;

  // reduce_window_c14
  SmallVector<ShapedType> resultTypes;
  std::optional<ArrayRef<int64_t>> resultShape;
  for (auto result : getResults()) {
    auto resultType = result.getType().dyn_cast<ShapedType>();
    resultTypes.push_back(resultType);
    if (!resultType) return op_.emitError() << "expects results to be tensors";

    if (!resultType.hasRank()) continue;
    if (!resultShape) resultShape = resultType.getShape();
    if (resultType.getShape() != *resultShape)
      return op_.emitError() << "expects all results to have the same shape";
  }

  // reduce_window_c15
  // Verifying this constraint would require knowing the actual values of
  // window_dimensions, window_strides, etc.
  // While we certainly can try to check whether they are constants and
  // verify them in that case, that seems like too much at this point.

  // reduce_window_c16
  for (auto [resultType, initValueType] :
       llvm::zip(resultTypes, initValueTypes)) {
    if (resultType.getElementType() != initValueType.getElementType())
      return op_.emitError() << "expects results and init_values (operands "
                             << numInputs << ".." << numInputs * 2 << ") "
                             << "to have pairwise the same element types";
  }

  return success();
}

ValueRange DynamicReduceWindowOpAdaptor::getInputs() {
  auto numInputs = (op_.getInputs().size() - 5) / 2;
  return op_.getInputs().slice(0, numInputs);
}

ValueRange DynamicReduceWindowOpAdaptor::getInitValues() {
  auto numInputs = (op_.getInputs().size() - 5) / 2;
  return op_.getInputs().slice(numInputs, numInputs);
}

Value DynamicReduceWindowOpAdaptor::getWindowDimensions() {
  return op_.getInputs()[op_.getInputs().size() - 5];
}

Value DynamicReduceWindowOpAdaptor::getWindowStrides() {
  return op_.getInputs()[op_.getInputs().size() - 4];
}

Value DynamicReduceWindowOpAdaptor::getBaseDilations() {
  return op_.getInputs()[op_.getInputs().size() - 3];
}

Value DynamicReduceWindowOpAdaptor::getWindowDilations() {
  return op_.getInputs()[op_.getInputs().size() - 2];
}

Value DynamicReduceWindowOpAdaptor::getPadding() {
  return op_.getInputs()[op_.getInputs().size() - 1];
}

Region& DynamicReduceWindowOpAdaptor::getBody() {
  auto bodyAttr = op_.getCalledComputations()[0].cast<FlatSymbolRefAttr>();
  auto bodyFunc =
      op_->getParentOfType<ModuleOp>().lookupSymbol<func::FuncOp>(bodyAttr);
  return bodyFunc.getBody();
}

std::optional<DynamicReduceWindowOpAdaptor> getDynamicReduceWindowOp(
    CustomCallOp op) {
  if (op.getCallTargetName() != "stablehlo.dynamic_reduce_window") return {};
  return DynamicReduceWindowOpAdaptor(op);
}

ValueRange DynamicReduceWindowOpAdaptor::getResults() {
  return op_.getResults();
}

}  // namespace stablehlo
}  // namespace mlir
