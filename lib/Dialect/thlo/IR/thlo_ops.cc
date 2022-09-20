/* Copyright 2022 The TensorFlow Authors. All Rights Reserved.

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

#include "mlir-hlo/Dialect/thlo/IR/thlo_ops.h"

#include <algorithm>
#include <iterator>
#include <memory>
#include <utility>

#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/Sequence.h"
#include "llvm/ADT/SmallVector.h"
#include "mlir-hlo/Dialect/gml_st/IR/gml_st_ops.h"
#include "mlir-hlo/Dialect/gml_st/transforms/tiling_interface.h"
#include "mlir/Dialect/Arithmetic/IR/Arithmetic.h"
#include "mlir/Dialect/Linalg/IR/LinalgInterfaces.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Tensor/Utils/Utils.h"
#include "mlir/Dialect/Utils/StructuredOpsUtils.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/TypeUtilities.h"

namespace mlir {
namespace {

//===----------------------------------------------------------------------===//
// Destination-style ops tools
//===----------------------------------------------------------------------===//

LogicalResult verifyDestinationStyleOp(Operation *op) {
  auto dstStyleOp = cast<linalg::DestinationStyleOpInterface>(*op);
  if (dstStyleOp.hasBufferSemantics()) return success(op->getNumResults() == 0);

  if (!dstStyleOp.hasTensorSemantics())
    return op->emitOpError("expected either buffer or tensor semantics");

  return success();
}

template <typename DstOpTy>
void printDstStyleOp(
    DstOpTy op, OpAsmPrinter &p,
    function_ref<SmallVector<StringRef>(DstOpTy op, OpAsmPrinter &)>
        printAttrsFn = nullptr) {
  if (op.getNumInputs() != 0) {
    p << " ins(";
    llvm::interleaveComma(
        op.getOperands().take_front(op.getNumInputs()), p,
        [&](Value input) { p << input << " : " << input.getType(); });
    p << ")";
  }
  p << " outs(";
  llvm::interleaveComma(
      op.getOperands().take_back(op.getNumOutputs()), p,
      [&](Value output) { p << output << " : " << output.getType(); });
  p << ")";

  // Print attributes with custom printing logic.
  SmallVector<StringRef> elidedAttrs;
  if (printAttrsFn) elidedAttrs = printAttrsFn(op, p);

  p.printOptionalAttrDict(op->getAttrs(), elidedAttrs);
}

ParseResult parseKeywordOperandListWithTypes(
    OpAsmParser &parser, OperationState &result, StringRef keyword,
    SmallVectorImpl<Type> *operandTypes) {
  SmallVector<OpAsmParser::UnresolvedOperand, 4> operands;
  if (succeeded(parser.parseOptionalKeyword(keyword))) {
    SMLoc operandsOperandsLoc = parser.getCurrentLocation();

    if (parser.parseCommaSeparatedList(
            AsmParser::Delimiter::Paren, [&]() -> ParseResult {
              if (parser.parseOperand(operands.emplace_back(),
                                      /*allowResultNumber=*/false) ||
                  parser.parseColon() ||
                  parser.parseType(operandTypes->emplace_back())) {
                return failure();
              }
              return success();
            }))
      return failure();

    if (parser.resolveOperands(operands, *operandTypes, operandsOperandsLoc,
                               result.operands))
      return failure();
  }
  return success();
}

ParseResult parseDstStyleOp(
    OpAsmParser &parser, OperationState &result,
    function_ref<ParseResult(OpAsmParser &, NamedAttrList &)> parseAttrsFn =
        nullptr) {
  // Parse `ins` and `outs`.
  SmallVector<Type, 4> inputTypes, outputTypes;
  if (parseKeywordOperandListWithTypes(parser, result, "ins", &inputTypes) ||
      parseKeywordOperandListWithTypes(parser, result, "outs", &outputTypes))
    return failure();

  // Add result types.
  for (Type outputType : outputTypes) {
    if (outputType.isa<RankedTensorType>()) result.addTypes(outputType);
  }

  // Parse required attributes.
  if (parseAttrsFn && failed(parseAttrsFn(parser, result.attributes)))
    return failure();

  // Parse optional attributes.
  if (parser.parseOptionalAttrDict(result.attributes)) return failure();
  return success();
}

ParseResult parseDenseI64ArrayAttr(OpAsmParser &parser,
                                   NamedAttrList &attributes,
                                   StringRef attributeName) {
  if (parser.parseKeyword(attributeName) || parser.parseEqual())
    return failure();

  attributes.set(attributeName, DenseI64ArrayAttr::parse(parser, Type{}));
  return success();
}

void printDenseI64ArrayAttr(OpAsmPrinter &p, StringRef attributeName,
                            ArrayRef<int64_t> attributeValue) {
  p << " " << attributeName << " = [" << attributeValue << "] ";
}

bool dimensionsMatch(int64_t d1, int64_t d2) {
  return ShapedType::isDynamic(d1) || ShapedType::isDynamic(d2) || d1 == d2;
}

SmallVector<StringRef> getParallelIteratorTypes(int64_t dimCount) {
  return SmallVector<StringRef>(dimCount, getParallelIteratorTypeName());
}

SmallVector<Range> getIterationDomainForTensor(OpBuilder &b, Location loc,
                                               Value tensor,
                                               int64_t dimCount = -1) {
  auto dimValues = tensor::createDimValues(b, loc, tensor);
  if (dimCount >= 0) dimValues.resize(dimCount);
  return llvm::to_vector(llvm::map_range(dimValues, [&](Value d) {
    return Range{b.getIndexAttr(0), d, b.getIndexAttr(1)};
  }));
}

Value getMaterializedTile(OpBuilder &b, Location loc,
                          TypedValue<TensorType> tensor,
                          ArrayRef<OpFoldResult> offsets,
                          ArrayRef<OpFoldResult> sizes) {
  SmallVector<Value> dynamicDims =
      tensor::createDynamicDimValues(b, loc, tensor);
  ArrayAttr staticDims = b.getI64ArrayAttr(tensor.getType().getShape());
  Value space = b.create<gml_st::SpaceOp>(loc, dynamicDims, staticDims);

  SmallVector<OpFoldResult> strides(offsets.size(), b.getIndexAttr(1));
  Value tile = b.create<gml_st::TileOp>(loc, space, offsets, sizes, strides);
  return b.create<gml_st::MaterializeOp>(loc, tensor, tile);
}

}  // namespace
}  // namespace mlir

// Generated dialect definitions.
#include "mlir-hlo/Dialect/thlo/IR/thlo_dialect.cc.inc"

namespace mlir {
namespace thlo {

void THLODialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "mlir-hlo/Dialect/thlo/IR/thlo_ops.cc.inc"
      >();
}

//===----------------------------------------------------------------------===//
// ConcatenateOp
//===----------------------------------------------------------------------===//

namespace {

gml_st::TileOp createTileOp(OpBuilder &b, Location loc, Value tensor,
                            ArrayRef<OpFoldResult> offsets,
                            ArrayRef<OpFoldResult> sizes) {
  auto initTy = tensor.getType().cast<RankedTensorType>();
  SmallVector<OpFoldResult> unitStrides(initTy.getRank(), b.getIndexAttr(1));
  SmallVector<Value> dynamicSpaceSizes =
      tensor::createDynamicDimValues(b, loc, tensor);
  ArrayAttr staticSpaceSizes = b.getI64ArrayAttr(initTy.getShape());
  auto space =
      b.create<gml_st::SpaceOp>(loc, dynamicSpaceSizes, staticSpaceSizes);
  return b.create<gml_st::TileOp>(loc, space, offsets, sizes, unitStrides);
}

}  // namespace

SmallVector<StringRef> ConcatenateOp::getLoopIteratorTypes() {
  return getParallelIteratorTypes(getInit().getType().getRank());
}

SmallVector<Value> ConcatenateOp::getDestinationOperands(OpBuilder &) {
  return {getInit()};
}

SmallVector<Range> ConcatenateOp::getIterationDomain(OpBuilder &b) {
  return getIterationDomainForTensor(b, getLoc(), getInit());
}

namespace {

// TODO(frgossen): Fuse this as a switch statement if all the operands are unit
// size in the concatenation dimension.
Value fuseConcatenateOpThroughTile(ConcatenateOp op, OpBuilder &builder,
                                   Location loc, Value tile) {
  uint64_t concatDim = op.getDimension();
  auto resultTy = op.getResult().getType().cast<RankedTensorType>();
  int64_t rank = resultTy.getRank();
  OperandRange allOperands = op.operands();
  Value anyOperand = allOperands.front();

  // Create the shared tile strides, which are the exact same for every operand
  // tile. Also create a basis for the space sizes, tile offsets, and tile
  // sizes. These hold the shared values in all non-concat dimensions and can be
  // amended in the concat dimension to create the individual operand tiles.
  SmallVector<Value> sharedTileStrides(rank);
  SmallVector<Value> baseSpaceSizes(rank);
  SmallVector<Value> baseTileOffsets(rank);
  SmallVector<Value> baseTileSizes(rank);
  for (int64_t i = 0; i < rank; ++i) {
    Value iCst = builder.create<arith::ConstantIndexOp>(loc, i);
    sharedTileStrides[i] = builder.create<gml_st::StrideOp>(loc, tile, iCst);

    // The space sizes, tile offsets, and tile sizes differ in the concat
    // dimension. Do not populate these.
    if (i == static_cast<int64_t>(concatDim)) {
      continue;
    }

    baseSpaceSizes[i] =
        builder.createOrFold<tensor::DimOp>(loc, anyOperand, iCst);
    baseTileOffsets[i] = builder.create<gml_st::OffsetOp>(loc, tile, iCst);
    baseTileSizes[i] = builder.create<gml_st::SizeOp>(loc, tile, iCst);
  }

  // Some shared values.
  ArrayAttr allDynamicStridesOrOffsetsAttr = builder.getI64ArrayAttr(
      SmallVector<int64_t>(rank, ShapedType::kDynamicStrideOrOffset));
  ArrayAttr allDynamicSizesAttr = builder.getI64ArrayAttr(
      SmallVector<int64_t>(rank, ShapedType::kDynamicSize));
  Value zeroCst = builder.create<arith::ConstantIndexOp>(loc, 0);
  Value concatDimCst = builder.create<arith::ConstantIndexOp>(loc, concatDim);
  Value maxTileSizeInConcatDim =
      builder.create<gml_st::SizeOp>(loc, tile, concatDimCst);

  // The remaining tile offset in the concat dimension is subtracted by each
  // operand's size in that dimension. We maintain the invariant
  // remainingTileOffsetInConcatDim >= 0.
  Value remainingTileOffsetInConcatDim =
      builder.create<gml_st::OffsetOp>(loc, tile, concatDimCst);

  // Create the relevant subsets per operand. These tiles can be empty at
  // runtime.
  SmallVector<Value> subOperands;
  subOperands.reserve(allOperands.size());
  for (Value operand : allOperands) {
    // Create operand space.
    Value operandSizeInConcatDim =
        builder.create<tensor::DimOp>(loc, operand, concatDimCst);
    baseSpaceSizes[concatDim] = operandSizeInConcatDim;
    Value operandSpace = builder.create<gml_st::SpaceOp>(loc, baseSpaceSizes,
                                                         allDynamicSizesAttr);

    // Find the current operand's tile offset in the concat dimension. This is
    // the remaining offset clamped into the bounds of the operand. Note that
    // the remaining offset is always >= 0.
    Value operandTileOffsetInConcatDim = builder.create<arith::MinUIOp>(
        loc, remainingTileOffsetInConcatDim, operandSizeInConcatDim);
    baseTileOffsets[concatDim] = operandTileOffsetInConcatDim;

    // Find the current operand's tile size in the concat dimension.
    Value remainingOperandSizeInConcatDim = builder.create<arith::SubIOp>(
        loc, operandSizeInConcatDim, operandTileOffsetInConcatDim);
    baseTileSizes[concatDim] = builder.create<arith::MinUIOp>(
        loc, remainingOperandSizeInConcatDim, maxTileSizeInConcatDim);

    // Create the operand tile and materialize the subset for this operand.
    Value tile = builder.create<gml_st::TileOp>(
        loc, operandSpace, baseTileOffsets, baseTileSizes, sharedTileStrides,
        allDynamicStridesOrOffsetsAttr, allDynamicSizesAttr,
        allDynamicStridesOrOffsetsAttr);
    subOperands.push_back(
        builder.create<gml_st::MaterializeOp>(loc, operand, tile));

    // Unless it is the last operand, update the remaining tile offset in the
    // concat dimension. The remaining offset is subtracted by the operand's
    // size but must remain >= 0.
    if (operand != allOperands.back()) {
      Value cmp = builder.create<arith::CmpIOp>(loc, arith::CmpIPredicate::ule,
                                                remainingTileOffsetInConcatDim,
                                                operandSizeInConcatDim);
      Value sub = builder.create<arith::SubIOp>(
          loc, remainingTileOffsetInConcatDim, operandSizeInConcatDim);
      remainingTileOffsetInConcatDim =
          builder.create<arith::SelectOp>(loc, cmp, zeroCst, sub);
    }
  }

  // Create the tiled concat op.
  auto tileType = tile.getType().cast<gml_st::TileType>();
  Value subInit =
      builder.create<gml_st::MaterializeOp>(loc, op.getInit(), tile);
  auto subResultType =
      RankedTensorType::get(tileType.getShape(), resultTy.getElementType());
  return builder.create<thlo::ConcatenateOp>(loc, subResultType, subOperands,
                                             subInit, concatDim);
}

Value fuseConcatenateOpThroughPointRecursively(
    OpBuilder &builder, Location loc, RankedTensorType rankedTy,
    uint64_t concatDim, SmallVector<Value> &remainingOffsets,
    ValueRange remainingOperands) {
  // Bail if called for no operands.
  if (remainingOperands.empty()) {
    return {};
  }
  Value leadingOperand = remainingOperands.front();

  // Terminal case of exactly one operand.
  if (remainingOperands.size() == 1) {
    // Create operand space.
    SmallVector<Value> dynamicDims =
        tensor::createDynamicDimValues(builder, loc, leadingOperand);
    ArrayAttr staticDims = builder.getI64ArrayAttr(rankedTy.getShape());
    Value operandSpace =
        builder.create<gml_st::SpaceOp>(loc, dynamicDims, staticDims);

    // Create operand point.
    SmallVector<int64_t> allDynamicOffsets(rankedTy.getRank(),
                                           ShapedType::kDynamicStrideOrOffset);
    Value operandPoint = builder.create<gml_st::PointOp>(
        loc, operandSpace, remainingOffsets,
        builder.getI64ArrayAttr(allDynamicOffsets));

    return builder.create<gml_st::MaterializeOp>(loc, leadingOperand,
                                                 operandPoint);
  }

  // For more than 1 operand, distinguish between the leading operand and the
  // remainder.
  assert(remainingOperands.size() > 1 &&
         "expect more than 1 operand at this point");
  Value leadingOperandConcatDim =
      builder.create<tensor::DimOp>(loc, leadingOperand, concatDim);
  Value leadingOperandPredicate = builder.create<arith::CmpIOp>(
      loc, arith::CmpIPredicate::ult, remainingOffsets[concatDim],
      leadingOperandConcatDim);
  auto ifOp = builder.create<scf::IfOp>(
      loc, rankedTy.getElementType(), leadingOperandPredicate,
      [&](OpBuilder &builder, Location loc) {
        // For the leading operand, recur with the current offsets.
        Value fused = fuseConcatenateOpThroughPointRecursively(
            builder, loc, rankedTy, concatDim, remainingOffsets,
            leadingOperand);
        builder.create<scf::YieldOp>(loc, fused);
      },
      [&](OpBuilder &builder, Location loc) {
        // For the remaining operands, substract the leading operand's size from
        // the remaining offsets in the concatenation dimension.
        SmallVector<Value> thenRemainingOffsets(remainingOffsets.begin(),
                                                remainingOffsets.end());
        thenRemainingOffsets[concatDim] = builder.create<arith::SubIOp>(
            loc, remainingOffsets[concatDim], leadingOperandConcatDim);
        Value fused = fuseConcatenateOpThroughPointRecursively(
            builder, loc, rankedTy, concatDim, thenRemainingOffsets,
            remainingOperands.drop_front());
        builder.create<scf::YieldOp>(loc, fused);
      });
  return ifOp.getResults().front();
}

Value fuseConcatenateOpThroughPoint(ConcatenateOp op, OpBuilder &builder,
                                    Location loc, Value subset) {
  auto resultTy = op.getType().cast<RankedTensorType>();
  int64_t resultRank = resultTy.getRank();
  uint64_t concatDim = op.getDimension();

  // Materialize initial offsets.
  SmallVector<Value> initialOffsets;
  initialOffsets.reserve(resultRank);
  for (int64_t i = 0; i < resultRank; ++i) {
    initialOffsets.push_back(builder.create<gml_st::OffsetOp>(
        loc, subset, builder.create<arith::ConstantIndexOp>(loc, i)));
  }

  ValueRange initialOperands = op.operands();
  return fuseConcatenateOpThroughPointRecursively(
      builder, loc, resultTy, concatDim, initialOffsets, initialOperands);
}

}  // namespace

gml_st::TilingInterface ConcatenateOp::getTiledImplementation(
    OpBuilder &b, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  // Create tile subset.
  auto loc = getLoc();
  gml_st::TileOp tile = createTileOp(b, loc, getInit(), offsets, sizes);

  auto tiled = fuseConcatenateOpThroughTile(*this, b, loc, tile);
  return llvm::cast<gml_st::TilingInterface>(tiled.getDefiningOp());
}

FailureOr<Value> ConcatenateOp::generateResultTileValue(
    OpBuilder &b, unsigned resultNumber, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  assert(resultNumber == 0 && "expect unique result idx");
  return getTiledImplementation(b, offsets, sizes)->getResults().front();
}

Value ConcatenateOp::fuse(Location loc, Value subset, OpBuilder &builder) {
  Type subsetTy = subset.getType();
  if (subsetTy.isa<gml_st::TileType>()) {
    return fuseConcatenateOpThroughTile(*this, builder, loc, subset);
  }
  if (subsetTy.isa<gml_st::PointType>()) {
    return fuseConcatenateOpThroughPoint(*this, builder, loc, subset);
  }
  return {};
}

ParseResult ConcatenateOp::parse(OpAsmParser &parser, OperationState &result) {
  return parseDstStyleOp(parser, result);
}

void ConcatenateOp::print(OpAsmPrinter &p) { printDstStyleOp(*this, p); }

LogicalResult ConcatenateOp::verify() {
  return verifyDestinationStyleOp(getOperation());
}

//===----------------------------------------------------------------------===//
// DynamicBroadcastInDimOp
//===----------------------------------------------------------------------===//

ParseResult DynamicBroadcastInDimOp::parse(OpAsmParser &parser,
                                           OperationState &result) {
  return parseDstStyleOp(parser, result,
                         [&](OpAsmParser &parser, NamedAttrList &attributes) {
                           return parseDenseI64ArrayAttr(
                               parser, attributes, "broadcast_dimensions");
                         });
}

void DynamicBroadcastInDimOp::print(OpAsmPrinter &p) {
  printDstStyleOp<DynamicBroadcastInDimOp>(
      *this, p,
      [](DynamicBroadcastInDimOp op,
         OpAsmPrinter &p) -> SmallVector<StringRef> {
        printDenseI64ArrayAttr(p, op.getBroadcastDimensionsAttrName(),
                               op.getBroadcastDimensions());
        return {op.getBroadcastDimensionsAttrName()};
      });
}

LogicalResult DynamicBroadcastInDimOp::verify() {
  return verifyDestinationStyleOp(getOperation());
}

SmallVector<StringRef> DynamicBroadcastInDimOp::getLoopIteratorTypes() {
  return getParallelIteratorTypes(getInit().getType().getRank());
}

SmallVector<Value> DynamicBroadcastInDimOp::getDestinationOperands(
    OpBuilder &) {
  return {getInit()};
}

SmallVector<Range> DynamicBroadcastInDimOp::getIterationDomain(OpBuilder &b) {
  return getIterationDomainForTensor(b, getLoc(), getInit());
}

gml_st::TilingInterface DynamicBroadcastInDimOp::getTiledImplementation(
    OpBuilder &b, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  // Create tile subset.
  auto loc = getLoc();
  auto tile = createTileOp(b, loc, getInit(), offsets, sizes);

  // Create the needed constants only once.
  DenseMap<uint64_t, Value> localIndexConstants;
  auto getIndexConstant = [&](uint64_t c) -> Value {
    auto it = localIndexConstants.find(c);
    if (it != localIndexConstants.end()) return it->second;
    auto cst = b.create<arith::ConstantIndexOp>(loc, c);
    localIndexConstants[c] = cst;
    return cst;
  };

  // Materialize operand space.
  auto operandTy = getOperand().getType().cast<RankedTensorType>();
  auto operandSpaceTy = b.getType<gml_st::TileType>(operandTy.getShape());
  auto dynamicDims = tensor::createDynamicDimValues(b, loc, getOperand());
  auto staticDims = b.getI64ArrayAttr(operandTy.getShape());
  Value operandSpace =
      b.create<gml_st::SpaceOp>(loc, operandSpaceTy, dynamicDims, staticDims);

  // Materialize operand dimensions.
  SmallVector<Value> operandDims;
  int64_t dynamicDimsIdx = 0;
  operandDims.reserve(operandTy.getRank());
  for (const auto &it : llvm::enumerate(operandTy.getShape())) {
    int64_t d = it.value();
    Value dim = d == ShapedType::kDynamicSize ? dynamicDims[dynamicDimsIdx++]
                                              : getIndexConstant(d);
    operandDims.push_back(dim);
  }

  // Collapse the subset to operate only on corresponding dimensions.
  // TODO(frgossen): Only generate this when needed.
  auto collapsedSubset =
      b.create<gml_st::DropDimsOp>(loc, tile, getBroadcastDimensionsAttr());

  // Find the expanding dimensions. If corresponding operand and result
  // dimensions are different then the dimension is expanding.
  // TODO(frgossen): Use info from known expanding and known non-expanding
  // dimensions here.
  SmallVector<Value> operandExpandingDims;
  for (const auto &it : llvm::enumerate(getBroadcastDimensions())) {
    auto operandDim = operandDims[it.index()];
    auto resultDim =
        b.create<tensor::DimOp>(loc, getInit(), getIndexConstant(it.value()));
    operandExpandingDims.push_back(b.create<arith::CmpIOp>(
        loc, arith::CmpIPredicate::ne, operandDim, resultDim));
  }

  // Compute operand tile offsets.
  int64_t operandRank = operandTy.getRank();
  auto staticOffsets = b.getI64ArrayAttr(
      SmallVector<int64_t>(operandRank, ShapedType::kDynamicStrideOrOffset));
  SmallVector<Value> operandOffsets;
  Value zero = getIndexConstant(0);
  for (int i = 0; i < operandRank; ++i) {
    Value isExpanding = operandExpandingDims[i];
    Value collapsedSubsetOffset =
        b.create<gml_st::OffsetOp>(loc, collapsedSubset, getIndexConstant(i));
    operandOffsets.push_back(b.create<arith::SelectOp>(loc, isExpanding, zero,
                                                       collapsedSubsetOffset));
  }

  // Compute operand tile sizes.
  auto staticTileSizes = b.getI64ArrayAttr(
      SmallVector<int64_t>(operandRank, ShapedType::kDynamicSize));
  SmallVector<Value> tileSizes;
  Value one = getIndexConstant(1);
  for (int i = 0; i < operandRank; ++i) {
    Value isExpanding = operandExpandingDims[i];
    Value tileSize =
        b.create<gml_st::SizeOp>(loc, collapsedSubset, getIndexConstant(i));
    tileSizes.push_back(
        b.create<arith::SelectOp>(loc, isExpanding, one, tileSize));
  }

  // Create operand tile.
  auto staticTileStrides =
      b.getI64ArrayAttr(SmallVector<int64_t>(operandRank, 1));
  SmallVector<Value> tileStrides = {};
  auto operandTileTy = b.getType<gml_st::TileType>(
      SmallVector<int64_t>(operandRank, ShapedType::kDynamicSize));
  auto operandTile = b.create<gml_st::TileOp>(
      loc, operandTileTy, operandSpace, operandOffsets, tileSizes, tileStrides,
      staticOffsets, staticTileSizes, staticTileStrides);

  // Materialize operand tiles.
  Value tiledInit = b.create<gml_st::MaterializeOp>(loc, getInit(), tile);
  Value tiledOperand =
      b.create<gml_st::MaterializeOp>(loc, getOperand(), operandTile);

  // Finally, materialize tiled broadcast.
  auto tileTy = tile.getType();
  auto resultTy = getResult().getType().cast<RankedTensorType>();
  auto tiledResultTy =
      RankedTensorType::get(tileTy.getShape(), resultTy.getElementType());
  return b.create<DynamicBroadcastInDimOp>(
      loc, TypeRange{tiledResultTy}, tiledOperand, tiledInit,
      getBroadcastDimensionsAttr(), getKnownExpandingDimensionsAttr(),
      getKnownNonexpandingDimensionsAttr());
}

FailureOr<Value> DynamicBroadcastInDimOp::generateResultTileValue(
    OpBuilder &b, unsigned resultNumber, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  assert(resultNumber == 0 && "expect unique result idx");
  return getTiledImplementation(b, offsets, sizes)->getResults().front();
}

Value DynamicBroadcastInDimOp::fuse(Location loc, Value subset,
                                    OpBuilder &builder) {
  Type subsetTy = subset.getType();
  auto operandTy = getOperand().getType().cast<RankedTensorType>();
  auto resultTy = getResult().getType().cast<RankedTensorType>();
  int64_t operandRank = operandTy.getRank();

  // Create the needed constants only once.
  DenseMap<uint64_t, Value> localIndexConstants;
  auto getIndexConstant = [&](uint64_t c) -> Value {
    auto it = localIndexConstants.find(c);
    if (it != localIndexConstants.end()) return it->second;
    auto cst = builder.create<arith::ConstantIndexOp>(loc, c);
    localIndexConstants[c] = cst;
    return cst;
  };

  // Materialize operand space.
  auto operandSpaceTy = builder.getType<gml_st::TileType>(operandTy.getShape());
  auto dynamicDims = tensor::createDynamicDimValues(builder, loc, getOperand());
  auto staticDims = builder.getI64ArrayAttr(operandTy.getShape());
  Value operandSpace = builder.create<gml_st::SpaceOp>(loc, operandSpaceTy,
                                                       dynamicDims, staticDims);

  // Materialize operand dimensions.
  SmallVector<Value> operandDims;
  int64_t dynamicDimsIdx = 0;
  operandDims.reserve(operandTy.getRank());
  for (const auto &it : llvm::enumerate(operandTy.getShape())) {
    int64_t d = it.value();
    Value dim = d == ShapedType::kDynamicSize ? dynamicDims[dynamicDimsIdx++]
                                              : getIndexConstant(d);
    operandDims.push_back(dim);
  }

  // Collapse the subset to operate only on corresponding dimensions.
  // TODO(frgossen): Only generate this when needed.
  auto collapsedSubset = builder.create<gml_st::DropDimsOp>(
      loc, subset, getBroadcastDimensionsAttr());

  // Find the expanding dimensions. If corresponding operand and result
  // dimensions are different then the dimension is expanding.
  // TODO(frgossen): Use info from known expanding and known non-expanding
  // dimensions here.
  SmallVector<Value> operandExpandingDims;
  for (const auto &it : llvm::enumerate(getBroadcastDimensions())) {
    auto operandDim = operandDims[it.index()];
    auto resultDim = builder.create<tensor::DimOp>(
        loc, getInit(), getIndexConstant(it.value()));
    operandExpandingDims.push_back(builder.create<arith::CmpIOp>(
        loc, arith::CmpIPredicate::ne, operandDim, resultDim));
  }

  // Compute operand offsets, which are needed for tile and point subsets.
  auto staticOffsets = builder.getI64ArrayAttr(
      SmallVector<int64_t>(operandRank, ShapedType::kDynamicStrideOrOffset));
  SmallVector<Value> offsets;
  Value zero = getIndexConstant(0);
  for (int i = 0; i < operandRank; ++i) {
    Value isExpanding = operandExpandingDims[i];
    Value collapsedSubsetOffset = builder.create<gml_st::OffsetOp>(
        loc, collapsedSubset, getIndexConstant(i));
    offsets.push_back(builder.create<arith::SelectOp>(loc, isExpanding, zero,
                                                      collapsedSubsetOffset));
  }

  // If the regarded subset is of point type, we can already construct the
  // operand point and materialize it.
  if (auto pointTy = subsetTy.dyn_cast<gml_st::PointType>()) {
    auto operandPoint = builder.create<gml_st::PointOp>(
        loc, pointTy, operandSpace, offsets, staticOffsets);
    return builder.create<gml_st::MaterializeOp>(
        loc, operandTy.getElementType(), getOperand(), operandPoint);
  }

  // If the regarded subset is of tile type, we still need the operand tile
  // sizes to materialize a fused broadcast.
  if (auto tileTy = subsetTy.dyn_cast<gml_st::TileType>()) {
    // Compute operand tile sizes.
    auto staticTileSizes = builder.getI64ArrayAttr(
        SmallVector<int64_t>(operandRank, ShapedType::kDynamicSize));
    SmallVector<Value> tileSizes;
    Value one = getIndexConstant(1);
    for (int i = 0; i < operandRank; ++i) {
      Value isExpanding = operandExpandingDims[i];
      Value tileSize = builder.create<gml_st::SizeOp>(loc, collapsedSubset,
                                                      getIndexConstant(i));
      tileSizes.push_back(
          builder.create<arith::SelectOp>(loc, isExpanding, one, tileSize));
    }

    // Create operand tile.
    auto staticTileStrides =
        builder.getI64ArrayAttr(SmallVector<int64_t>(operandRank, 1));
    SmallVector<Value> tileStrides = {};
    auto operandTileTy = builder.getType<gml_st::TileType>(
        SmallVector<int64_t>(operandRank, ShapedType::kDynamicSize));
    auto operandTile = builder.create<gml_st::TileOp>(
        loc, operandTileTy, operandSpace, offsets, tileSizes, tileStrides,
        staticOffsets, staticTileSizes, staticTileStrides);

    // Materialize operand subsets.
    Value tiledInit =
        builder.create<gml_st::MaterializeOp>(loc, getInit(), subset);
    Value tiledOperand =
        builder.create<gml_st::MaterializeOp>(loc, getOperand(), operandTile);

    // Finally, materialize tiled broadcast.
    auto tiledResultTy =
        RankedTensorType::get(tileTy.getShape(), resultTy.getElementType());
    return builder.create<DynamicBroadcastInDimOp>(
        loc, TypeRange{tiledResultTy}, tiledOperand, tiledInit,
        getBroadcastDimensionsAttr(), getKnownExpandingDimensionsAttr(),
        getKnownNonexpandingDimensionsAttr());
  }

  return {};
}

//===----------------------------------------------------------------------===//
// ScatterOp
//===----------------------------------------------------------------------===//

ParseResult ScatterOp::parse(OpAsmParser &parser, OperationState &result) {
  if (parseDstStyleOp(parser, result)) return failure();

  SmallVector<OpAsmParser::Argument> regionArgs;
  if (parser.parseArgumentList(regionArgs, OpAsmParser::Delimiter::Paren,
                               /*allowType=*/true, /*allowAttrs=*/true)) {
    return failure();
  }

  Region *body = result.addRegion();
  if (parser.parseRegion(*body, regionArgs)) return failure();

  return success();
}

void ScatterOp::print(OpAsmPrinter &p) {
  printDstStyleOp<ScatterOp>(*this, p);

  p << "(";
  llvm::interleaveComma(getUpdateComputation().getArguments(), p,
                        [&](auto arg) { p.printRegionArgument(arg); });
  p << ") ";

  p.printRegion(getUpdateComputation(), /*printEntryBlockArgs=*/false);
}

LogicalResult ScatterOp::verify() {
  if (failed(verifyDestinationStyleOp(getOperation()))) return failure();

  auto indicesShapeWithoutVectorDim =
      getIndices().getType().getShape().drop_back(1);
  if (indicesShapeWithoutVectorDim !=
      getUpdates().getType().cast<ShapedType>().getShape()) {
    return emitOpError(
        "Expected indices.shape to be updates.shape + [index_vector_dim_size]");
  }

  return success();
}

SmallVector<StringRef> ScatterOp::getLoopIteratorTypes() {
  auto indicesRank = getIndices().getType().getRank();
  return SmallVector<StringRef>(indicesRank - 1, getParallelIteratorTypeName());
}

SmallVector<Value> ScatterOp::getDestinationOperands(OpBuilder &) {
  return {getInit()};
}

SmallVector<Range> ScatterOp::getIterationDomain(OpBuilder &b) {
  return getIterationDomainForTensor(b, getLoc(), getUpdates());
}

static Value getSlice(OpBuilder &b, Location loc, Value tensor,
                      ArrayRef<OpFoldResult> offsets,
                      ArrayRef<OpFoldResult> sizes) {
  auto tensorType = tensor.getType().cast<RankedTensorType>();
  SmallVector<Value> dynSizes = tensor::createDynamicDimValues(b, loc, tensor);
  auto staticSizes = b.getI64ArrayAttr(tensorType.getShape());

  Value space = b.create<gml_st::SpaceOp>(loc, dynSizes, staticSizes);
  if (sizes.empty()) return b.create<gml_st::MaterializeOp>(loc, tensor, space);

  SmallVector<OpFoldResult> strides(offsets.size(), b.getIndexAttr(1));
  Value tile = b.create<gml_st::TileOp>(loc, space, offsets, sizes, strides);
  return b.create<gml_st::MaterializeOp>(loc, tensor, tile);
}

mlir::gml_st::TilingInterface ScatterOp::getTiledImplementation(
    OpBuilder &b, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  Location loc = getLoc();

  Value update = this->getUpdates();
  Value updateSlice = getSlice(b, loc, update, offsets, sizes);

  Value indices = this->getIndices();
  auto indicesOffsets = to_vector(offsets);
  indicesOffsets.push_back(b.getIndexAttr(0));
  auto indicesSizes = to_vector(sizes);
  auto indicesType = indices.getType().cast<RankedTensorType>();
  indicesSizes.push_back(b.getIndexAttr(indicesType.getShape().back()));
  Value indicesSlice = getSlice(b, loc, indices, indicesOffsets, indicesSizes);

  Value init = this->getInit();
  Value initSlice = getSlice(b, loc, init, llvm::None, llvm::None);

  auto dpsInterface =
      cast<linalg::DestinationStyleOpInterface>(this->getOperation());
  return dpsInterface.clone(b, loc, TypeRange{initSlice.getType()},
                            ValueRange{indicesSlice, updateSlice, initSlice});
}

FailureOr<Value> ScatterOp::generateResultTileValue(
    OpBuilder &b, unsigned resultNumber, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  assert(resultNumber == 0 && "variadic scatter is not implemented");
  return getTiledImplementation(b, offsets, sizes)->getResult(0);
}

//===----------------------------------------------------------------------===//
// GatherOp
//===----------------------------------------------------------------------===//

ParseResult GatherOp::parse(OpAsmParser &parser, OperationState &result) {
  return parseDstStyleOp(parser, result);
}

void GatherOp::print(OpAsmPrinter &p) { printDstStyleOp(*this, p); }

LogicalResult GatherOp::verify() {
  return verifyDestinationStyleOp(getOperation());
}

SmallVector<StringRef> GatherOp::getLoopIteratorTypes() {
  // Currently, `offset_dims` is empty, so the iteration domain is just the
  // entire output.
  return getParallelIteratorTypes(getInit().getType().getRank());
}

SmallVector<Value> GatherOp::getDestinationOperands(OpBuilder &) {
  return {getInit()};
}

SmallVector<Range> GatherOp::getIterationDomain(OpBuilder &b) {
  // Currently, `offset_dims` is empty, so the iteration domain is just the
  // entire output.
  return getIterationDomainForTensor(b, getLoc(), getInit());
}

mlir::gml_st::TilingInterface GatherOp::getTiledImplementation(
    OpBuilder &b, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  auto offsetsWithVectorDim = offsets.vec();
  auto sizesWithVectorDim = sizes.vec();

  offsetsWithVectorDim.emplace_back(b.getIndexAttr(0));
  sizesWithVectorDim.emplace_back(
      b.getIndexAttr(getStartIndices().getType().getShape().back()));

  llvm::SmallVector<OpFoldResult> strides(offsets.size() + 1,
                                          b.getIndexAttr(1));

  auto subStartIndices = b.create<tensor::ExtractSliceOp>(
      getLoc(), getStartIndices(), offsetsWithVectorDim, sizesWithVectorDim,
      strides);
  Value initSlice = getMaterializedTile(b, getLoc(), getInit(), offsets, sizes);

  return b
      .create<GatherOp>(getLoc(), TypeRange{initSlice.getType()},
                        ValueRange{getOperand(), subStartIndices, initSlice})
      .getOperation();
}

FailureOr<Value> GatherOp::generateResultTileValue(
    OpBuilder &b, unsigned resultNumber, ArrayRef<OpFoldResult> offsets,
    ArrayRef<OpFoldResult> sizes) {
  assert(resultNumber == 0 && "resultNumber > 0 not implemented");
  return getTiledImplementation(b, offsets, sizes)->getResult(0);
}

//===----------------------------------------------------------------------===//
// TransposeOp
//===----------------------------------------------------------------------===//

ParseResult TransposeOp::parse(OpAsmParser &parser, OperationState &result) {
  return parseDstStyleOp(
      parser, result, [&](OpAsmParser &parser, NamedAttrList &attributes) {
        return parseDenseI64ArrayAttr(parser, attributes, "permutation");
      });
}

void TransposeOp::print(OpAsmPrinter &p) {
  printDstStyleOp<TransposeOp>(
      *this, p, [](TransposeOp op, OpAsmPrinter &p) -> SmallVector<StringRef> {
        printDenseI64ArrayAttr(p, op.getPermutationAttrName(),
                               op.getPermutation());
        return {op.getPermutationAttrName()};
      });
}

bool isValidPermutation(ArrayRef<int64_t> permutation) {
  SmallVector<bool> seen(permutation.size(), false);
  for (auto p : permutation) {
    // Verify that each element is in [0..n-1] range and is present only once.
    if (p < 0 || p >= static_cast<int64_t>(permutation.size()) || seen[p])
      return false;

    seen[p] = true;
  }
  return true;
}

LogicalResult TransposeOp::verify() {
  ArrayRef<int64_t> permutationRef = getPermutation();

  if (!isValidPermutation(permutationRef))
    return emitOpError("permutation is not valid");

  auto inputType = getInput().getType();
  auto initType = getInit().getType();

  int64_t rank = inputType.getRank();

  if (rank != initType.getRank())
    return emitOpError() << "input rank " << rank
                         << " does not match init rank " << initType.getRank();

  if (rank != static_cast<int64_t>(permutationRef.size()))
    return emitOpError() << "size of permutation " << permutationRef.size()
                         << " does not match the argument rank " << rank;

  auto inputDims = inputType.getShape();
  auto initDims = initType.getShape();

  for (int64_t i = 0; i < rank; ++i) {
    int64_t inputDim = inputDims[permutationRef[i]];
    int64_t initDim = initDims[i];

    if (!dimensionsMatch(inputDim, initDim)) {
      return emitOpError() << "dim(result, " << i << ") = " << initDim
                           << " doesn't match dim(input, permutation[" << i
                           << "]) = " << inputDim;
    }
  }
  return verifyDestinationStyleOp(getOperation());
}

//===----------------------------------------------------------------------===//
// ReductionOp
//===----------------------------------------------------------------------===//

ParseResult ReductionOp::parse(OpAsmParser &parser, OperationState &result) {
  if (parseDstStyleOp(
          parser, result, [&](OpAsmParser &parser, NamedAttrList &attributes) {
            return parseDenseI64ArrayAttr(parser, attributes, "dimensions");
          }))
    return failure();

  SmallVector<OpAsmParser::Argument> regionArgs;
  if (parser.parseArgumentList(regionArgs, OpAsmParser::Delimiter::Paren,
                               /*allowType=*/true, /*allowAttrs=*/true)) {
    return failure();
  }

  Region *body = result.addRegion();
  if (parser.parseRegion(*body, regionArgs)) return failure();

  return success();
}

void ReductionOp::print(OpAsmPrinter &p) {
  printDstStyleOp<ReductionOp>(
      *this, p, [](ReductionOp op, OpAsmPrinter &p) -> SmallVector<StringRef> {
        printDenseI64ArrayAttr(p, op.getDimensionsAttrName(),
                               op.getDimensions());
        return {op.getDimensionsAttrName()};
      });

  p << "(";
  llvm::interleaveComma(getCombiner().getArguments(), p,
                        [&](auto arg) { p.printRegionArgument(arg); });
  p << ") ";

  p.printRegion(getCombiner(), /*printEntryBlockArgs=*/false);
}

LogicalResult ReductionOp::verify() {
  ArrayRef<int64_t> dimensionsRef = getDimensions();

  for (int64_t i = 1; i < getNumInputs(); ++i) {
    if (failed(mlir::verifyCompatibleShape(getInputs()[i].getType(),
                                           getInputs()[0].getType()))) {
      return emitOpError() << "expects all inputs to have compatible shapes. "
                              "Shape at input-index "
                           << i
                           << " is not compatible with shape at input-index 0.";
    }
  }
  for (int64_t i = 1; i < getNumOutputs(); ++i) {
    if (failed(mlir::verifyCompatibleShape(getInits()[i].getType(),
                                           getInits()[0].getType()))) {
      return emitOpError()
             << "expects all outputs to have compatible shapes. "
                "Shape at output-index "
             << i << " is not compatible with shape at output-index 0.";
    }
  }
  auto inputType = getInputs()[0].getType().cast<ShapedType>();
  auto initType = getInits()[0].getType().cast<ShapedType>();

  DenseSet<int64_t> dimensionsToReduce;
  int64_t lastDimension = -1;
  for (int64_t dimension : dimensionsRef) {
    if (dimension < 0 || dimension >= inputType.getRank()) {
      return emitOpError()
             << "dimensions for reduction should be in the range [0, "
             << inputType.getRank() - 1 << "].";
    }
    if (dimension <= lastDimension) {
      return emitOpError()
             << "reduction dimensions are not in increasing order: "
             << dimensionsRef;
    }

    lastDimension = dimension;
    dimensionsToReduce.insert(dimension);
  }

  auto inputDims = inputType.getShape();
  auto initDims = initType.getShape();

  // Input dimensions that will be left after the reduction.
  SmallVector<int64_t> reducedInputDims;
  for (const auto &en : llvm::enumerate(inputDims)) {
    if (!dimensionsToReduce.count(en.index()))
      reducedInputDims.push_back(en.value());
  }

  if (reducedInputDims.size() != initType.getRank()) {
    return emitOpError() << "number of dimensions after reduction "
                         << reducedInputDims.size()
                         << " doesn't match the init rank "
                         << initType.getRank();
  }

  if (!all_of_zip(reducedInputDims, initDims, &dimensionsMatch))
    return emitOpError() << "init dimensions [" << initDims
                         << "] doesn't match input dimensions after reduction ["
                         << reducedInputDims << "]";

  Block *block = getBody();
  if (static_cast<int64_t>(block->getArguments().size()) !=
      getNumInputs() + getNumOutputs()) {
    return emitOpError()
           << "number of block arguments " << block->getArguments().size()
           << " doesn't match the number of inputs plus the number of outputs "
           << getNumInputs() + getNumOutputs();
  }

  // Check that the first block arguments match the element type of the inputs.
  auto inputElementTypes =
      llvm::to_vector<8>(llvm::map_range(getInputs().getTypes(), [](Type type) {
        return type.cast<ShapedType>().getElementType();
      }));
  auto blockArgumentInputTypes = llvm::to_vector<8>(
      llvm::map_range(block->getArguments().take_front(getNumInputs()),
                      [](BlockArgument arg) { return arg.getType(); }));
  if (blockArgumentInputTypes != inputElementTypes) {
    return emitOpError() << "input element types " << inputElementTypes
                         << " do not match block argument types "
                         << blockArgumentInputTypes;
  }

  // Check that the last block arguments match the element type of the outputs.
  auto outputElementTypes =
      llvm::to_vector<8>(llvm::map_range(getInits().getTypes(), [](Type type) {
        return type.cast<ShapedType>().getElementType();
      }));
  auto blockArgumentOutputTypes = llvm::to_vector<8>(
      llvm::map_range(block->getArguments().take_back(getNumOutputs()),
                      [](BlockArgument arg) { return arg.getType(); }));
  if (blockArgumentOutputTypes != outputElementTypes) {
    return emitOpError() << "output element types " << outputElementTypes
                         << " do not match block argument types "
                         << blockArgumentOutputTypes;
  }

  return verifyDestinationStyleOp(getOperation());
}

//===----------------------------------------------------------------------===//
// MapOp
//===----------------------------------------------------------------------===//

ParseResult MapOp::parse(OpAsmParser &parser, OperationState &result) {
  if (parseDstStyleOp(parser, result)) return failure();

  SmallVector<OpAsmParser::Argument> regionArgs;
  if (parser.parseArgumentList(regionArgs, OpAsmParser::Delimiter::Paren,
                               /*allowType=*/true, /*allowAttrs=*/true)) {
    return failure();
  }

  Region *body = result.addRegion();
  if (parser.parseRegion(*body, regionArgs)) return failure();

  return success();
}

void MapOp::print(OpAsmPrinter &p) {
  printDstStyleOp<MapOp>(*this, p);

  p << "(";
  llvm::interleaveComma(getMapper().getArguments(), p,
                        [&](auto arg) { p.printRegionArgument(arg); });
  p << ") ";

  p.printRegion(getMapper(), /*printEntryBlockArgs=*/false);
}

LogicalResult MapOp::verify() {
  auto *bodyBlock = getBody();
  auto blockArgs = bodyBlock->getArguments();

  // Checks if the number of `inputs` match the arity of the `mapper` region.
  if (getInputs().size() != blockArgs.size())
    return emitOpError() << "expects number of operands to match the arity of "
                            "mapper, but got: "
                         << getInputs().size() << " and " << blockArgs.size();

  // The parameters of mapper should all match the element type // of inputs.
  for (const auto &[bbArgType, inputArg] :
       llvm::zip(bodyBlock->getArgumentTypes(), getInputs())) {
    auto inputElemType = inputArg.getType().cast<ShapedType>().getElementType();
    if (bbArgType != inputElemType) {
      return emitOpError() << "expected element type of input " << inputElemType
                           << " to match bbArg type " << bbArgType;
    }
  }

  return verifyDestinationStyleOp(getOperation());
}

//===----------------------------------------------------------------------===//
// YieldOp
//===----------------------------------------------------------------------===//

LogicalResult YieldOp::verify() {
  auto parentOp = dyn_cast<linalg::DestinationStyleOpInterface>(
      *(getOperation()->getParentOp()));

  SmallVector<Value, 2> tensorOuts;
  llvm::copy_if(
      parentOp.outputs(), std::back_inserter(tensorOuts),
      [&](Value out) { return out.getType().isa<RankedTensorType>(); });
  if (tensorOuts.size() != getValues().size())
    return emitOpError("expects number of tensor output args = ")
           << tensorOuts.size()
           << " to match the number of yield operands = " << getValues().size();

  TypeRange tensorTypes{ValueRange{tensorOuts}};
  for (auto &item :
       llvm::enumerate(llvm::zip(tensorTypes, getOperandTypes()))) {
    Type outputType, resultType;
    unsigned index = item.index();
    std::tie(outputType, resultType) = item.value();
    Type outputElementType =
        outputType.cast<RankedTensorType>().getElementType();
    if (outputElementType != resultType)
      return emitOpError("expects yield operand ")
             << index << " with type = " << resultType
             << " to match output arg element type = " << outputElementType;
  }
  return success();
}

}  // namespace thlo
}  // namespace mlir

// Generated op classes.
#define GET_OP_CLASSES
#include "mlir-hlo/Dialect/thlo/IR/thlo_ops.cc.inc"
