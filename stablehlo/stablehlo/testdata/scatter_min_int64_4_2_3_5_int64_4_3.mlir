// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<4x2x3x5xi64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<[0, 4]> : tensor<2xi64>
    %0:2 = call @inputs() : () -> (tensor<4x2x3x5xi64>, tensor<4x3xi64>)
    %1 = call @expected() : () -> tensor<4x2x3x5xi64>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1, 3], scatter_dims_to_operand_dims = [1, 3]>, unique_indices = true}> ({
    ^bb0(%arg0: tensor<i64>, %arg1: tensor<i64>):
      %3 = stablehlo.minimum %arg0, %arg1 : tensor<i64>
      stablehlo.return %3 : tensor<i64>
    }) : (tensor<4x2x3x5xi64>, tensor<2xi64>, tensor<4x3xi64>) -> tensor<4x2x3x5xi64>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<4x2x3x5xi64>, tensor<4x2x3x5xi64>) -> ()
    return %2 : tensor<4x2x3x5xi64>
  }
  func.func private @inputs() -> (tensor<4x2x3x5xi64> {mhlo.layout_mode = "default"}, tensor<4x3xi64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x03000000000000000200000000000000FFFFFFFFFFFFFFFF040000000000000001000000000000000200000000000000FBFFFFFFFFFFFFFF00000000000000000100000000000000000000000000000000000000000000000500000000000000030000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFF0100000000000000040000000000000000000000000000000200000000000000000000000000000000000000000000000200000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF000000000000000001000000000000000000000000000000020000000000000003000000000000000000000000000000FAFFFFFFFFFFFFFF020000000000000002000000000000000200000000000000010000000000000001000000000000000000000000000000000000000000000004000000000000000000000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF03000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0100000000000000FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0100000000000000FDFFFFFFFFFFFFFF0200000000000000FEFFFFFFFFFFFFFF0500000000000000FCFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF08000000000000000100000000000000020000000000000001000000000000000200000000000000FDFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF02000000000000000100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000030000000000000001000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF04000000000000000000000000000000FCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0300000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF01000000000000000200000000000000FFFFFFFFFFFFFFFF000000000000000000000000000000000700000000000000FFFFFFFFFFFFFFFF03000000000000000100000000000000FDFFFFFFFFFFFFFF0200000000000000010000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFF030000000000000001000000000000000300000000000000FAFFFFFFFFFFFFFF"> : tensor<4x2x3x5xi64>
    %c_0 = stablehlo.constant dense<[[1, 0, -1], [-5, 0, 0], [0, 4, -1], [0, 1, -1]]> : tensor<4x3xi64>
    return %c, %c_0 : tensor<4x2x3x5xi64>, tensor<4x3xi64>
  }
  func.func private @expected() -> (tensor<4x2x3x5xi64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x03000000000000000200000000000000FFFFFFFFFFFFFFFF040000000000000001000000000000000200000000000000FBFFFFFFFFFFFFFF0000000000000000010000000000000000000000000000000000000000000000050000000000000003000000000000000000000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0100000000000000040000000000000000000000000000000200000000000000000000000000000000000000000000000200000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF000000000000000001000000000000000000000000000000020000000000000003000000000000000000000000000000FAFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF02000000000000000200000000000000010000000000000001000000000000000000000000000000000000000000000004000000000000000000000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF03000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0100000000000000FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0100000000000000FDFFFFFFFFFFFFFF0200000000000000FEFFFFFFFFFFFFFF0500000000000000FCFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF08000000000000000100000000000000020000000000000001000000000000000200000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF02000000000000000100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000030000000000000001000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF04000000000000000000000000000000FCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0300000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF01000000000000000200000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000700000000000000FFFFFFFFFFFFFFFF03000000000000000100000000000000FDFFFFFFFFFFFFFF0200000000000000010000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFF030000000000000001000000000000000300000000000000FAFFFFFFFFFFFFFF"> : tensor<4x2x3x5xi64>
    return %c : tensor<4x2x3x5xi64>
  }
}
