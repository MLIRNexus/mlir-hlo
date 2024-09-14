/* Copyright 2024 The StableHLO Authors. All Rights Reserved.
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

#include "stablehlo/transforms/passes_utils.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/Location.h"
#include "mlir/IR/TypeUtilities.h"
#include "mlir/IR/Types.h"
#include "mlir/IR/Value.h"
#include "mlir/Support/LLVM.h"
#include "stablehlo/dialect/ChloOps.h"

namespace mlir {
namespace stablehlo {

Value getConstantLike(OpBuilder &b, Location loc, const APFloat &constant,
                      Value val) {
  Type ty = getElementTypeOrSelf(val.getType());
  return b.create<mlir::chlo::ConstantLikeOp>(loc, b.getFloatAttr(ty, constant),
                                              val);
}

}  // namespace stablehlo
}  // namespace mlir
