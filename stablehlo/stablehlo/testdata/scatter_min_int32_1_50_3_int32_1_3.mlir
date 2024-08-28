// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<1x50x3xi32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<32> : tensor<1xi64>
    %0:2 = call @inputs() : () -> (tensor<1x50x3xi32>, tensor<1x3xi32>)
    %1 = call @expected() : () -> tensor<1x50x3xi32>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true}> ({
    ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):
      %3 = stablehlo.minimum %arg0, %arg1 : tensor<i32>
      stablehlo.return %3 : tensor<i32>
    }) : (tensor<1x50x3xi32>, tensor<1xi64>, tensor<1x3xi32>) -> tensor<1x50x3xi32>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<1x50x3xi32>, tensor<1x50x3xi32>) -> ()
    return %2 : tensor<1x50x3xi32>
  }
  func.func private @inputs() -> (tensor<1x50x3xi32> {mhlo.layout_mode = "default"}, tensor<1x3xi32> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0xF9FFFFFF010000000000000001000000F7FFFFFF0100000002000000060000000100000001000000000000000000000002000000000000000200000008000000FFFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFFFFFFFFFCFFFFFF00000000FCFFFFFFFEFFFFFF0000000000000000FFFFFFFF00000000FCFFFFFF01000000000000000000000000000000FCFFFFFFFEFFFFFF0600000001000000FFFFFFFF01000000FBFFFFFF030000000400000000000000FCFFFFFF000000000300000002000000FEFFFFFFFEFFFFFF0000000004000000FDFFFFFF020000000500000001000000000000000000000003000000FCFFFFFF0200000000000000FCFFFFFF0200000001000000FCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0300000001000000FFFFFFFFFFFFFFFF00000000F8FFFFFFFEFFFFFFFFFFFFFF000000000000000003000000FEFFFFFFFCFFFFFF00000000FDFFFFFF00000000FEFFFFFFFFFFFFFF01000000FCFFFFFFFDFFFFFF01000000010000000200000003000000000000000000000003000000FFFFFFFFFEFFFFFF000000000100000000000000FCFFFFFFFEFFFFFF01000000000000000500000003000000FCFFFFFFFCFFFFFFFDFFFFFF0500000000000000FFFFFFFFFFFFFFFF00000000FBFFFFFFFFFFFFFF00000000FEFFFFFF01000000FFFFFFFF00000000FDFFFFFFFCFFFFFF000000000600000001000000FFFFFFFF01000000FBFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000001000000FEFFFFFFFEFFFFFF00000000FDFFFFFF00000000010000000000000000000000FBFFFFFF00000000FDFFFFFFFCFFFFFFFEFFFFFF"> : tensor<1x50x3xi32>
    %c_0 = stablehlo.constant dense<[[0, -7, 0]]> : tensor<1x3xi32>
    return %c, %c_0 : tensor<1x50x3xi32>, tensor<1x3xi32>
  }
  func.func private @expected() -> (tensor<1x50x3xi32> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0xF9FFFFFF010000000000000001000000F7FFFFFF0100000002000000060000000100000001000000000000000000000002000000000000000200000008000000FFFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFFFFFFFFFCFFFFFF00000000FCFFFFFFFEFFFFFF0000000000000000FFFFFFFF00000000FCFFFFFF01000000000000000000000000000000FCFFFFFFFEFFFFFF0600000001000000FFFFFFFF01000000FBFFFFFF030000000400000000000000FCFFFFFF000000000300000002000000FEFFFFFFFEFFFFFF0000000004000000FDFFFFFF020000000500000001000000000000000000000003000000FCFFFFFF0200000000000000FCFFFFFF0200000001000000FCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0300000001000000FFFFFFFFFFFFFFFF00000000F8FFFFFFFEFFFFFFFFFFFFFF000000000000000003000000FEFFFFFFFCFFFFFF00000000FDFFFFFF00000000FEFFFFFFFFFFFFFF01000000FCFFFFFFFDFFFFFF01000000010000000200000003000000000000000000000000000000F9FFFFFFFEFFFFFF000000000100000000000000FCFFFFFFFEFFFFFF01000000000000000500000003000000FCFFFFFFFCFFFFFFFDFFFFFF0500000000000000FFFFFFFFFFFFFFFF00000000FBFFFFFFFFFFFFFF00000000FEFFFFFF01000000FFFFFFFF00000000FDFFFFFFFCFFFFFF000000000600000001000000FFFFFFFF01000000FBFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000001000000FEFFFFFFFEFFFFFF00000000FDFFFFFF00000000010000000000000000000000FBFFFFFF00000000FDFFFFFFFCFFFFFFFEFFFFFF"> : tensor<1x50x3xi32>
    return %c : tensor<1x50x3xi32>
  }
}
