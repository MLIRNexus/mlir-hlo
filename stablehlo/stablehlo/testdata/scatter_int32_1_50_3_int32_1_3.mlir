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
      stablehlo.return %arg1 : tensor<i32>
    }) : (tensor<1x50x3xi32>, tensor<1xi64>, tensor<1x3xi32>) -> tensor<1x50x3xi32>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<1x50x3xi32>, tensor<1x50x3xi32>) -> ()
    return %2 : tensor<1x50x3xi32>
  }
  func.func private @inputs() -> (tensor<1x50x3xi32> {mhlo.layout_mode = "default"}, tensor<1x3xi32> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x00000000FFFFFFFFFFFFFFFFFEFFFFFFFCFFFFFF04000000FDFFFFFF0400000001000000FDFFFFFFFBFFFFFFFCFFFFFF030000000000000000000000FAFFFFFFFEFFFFFF05000000FDFFFFFF0100000000000000020000000000000000000000FCFFFFFF0000000003000000020000000000000000000000FEFFFFFF000000000300000000000000020000000100000001000000FEFFFFFFFEFFFFFF0000000004000000020000000200000001000000FDFFFFFFFEFFFFFF020000000300000001000000020000000200000000000000FEFFFFFF020000000000000007000000FBFFFFFFFDFFFFFF0000000000000000FEFFFFFF000000000000000000000000FEFFFFFFFDFFFFFF030000000000000001000000FEFFFFFFFEFFFFFFFDFFFFFFFEFFFFFFFBFFFFFF05000000FFFFFFFF00000000FDFFFFFFFEFFFFFF0000000001000000FDFFFFFFFDFFFFFF00000000000000000000000006000000FBFFFFFF0000000002000000FDFFFFFFFFFFFFFFFFFFFFFF00000000FCFFFFFF06000000FEFFFFFF05000000010000000100000002000000050000000500000004000000FFFFFFFFFEFFFFFFFEFFFFFF00000000020000000000000000000000FDFFFFFF07000000FEFFFFFFFEFFFFFF0100000000000000FDFFFFFF02000000FEFFFFFF03000000FEFFFFFF0500000000000000030000000100000001000000010000000100000000000000FDFFFFFF0100000005000000FEFFFFFF0400000000000000FFFFFFFF0000000000000000000000000100000000000000FBFFFFFFFDFFFFFFFBFFFFFF03000000FFFFFFFF0300000003000000FEFFFFFF"> : tensor<1x50x3xi32>
    %c_0 = stablehlo.constant dense<[[0, -3, -4]]> : tensor<1x3xi32>
    return %c, %c_0 : tensor<1x50x3xi32>, tensor<1x3xi32>
  }
  func.func private @expected() -> (tensor<1x50x3xi32> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0x00000000FFFFFFFFFFFFFFFFFEFFFFFFFCFFFFFF04000000FDFFFFFF0400000001000000FDFFFFFFFBFFFFFFFCFFFFFF030000000000000000000000FAFFFFFFFEFFFFFF05000000FDFFFFFF0100000000000000020000000000000000000000FCFFFFFF0000000003000000020000000000000000000000FEFFFFFF000000000300000000000000020000000100000001000000FEFFFFFFFEFFFFFF0000000004000000020000000200000001000000FDFFFFFFFEFFFFFF020000000300000001000000020000000200000000000000FEFFFFFF020000000000000007000000FBFFFFFFFDFFFFFF0000000000000000FEFFFFFF000000000000000000000000FEFFFFFFFDFFFFFF030000000000000001000000FEFFFFFFFEFFFFFFFDFFFFFFFEFFFFFFFBFFFFFF05000000FFFFFFFF00000000FDFFFFFFFEFFFFFF0000000001000000FDFFFFFFFDFFFFFF00000000000000000000000006000000FBFFFFFF0000000002000000FDFFFFFFFFFFFFFFFFFFFFFF00000000FCFFFFFF0600000000000000FDFFFFFFFCFFFFFF0100000002000000050000000500000004000000FFFFFFFFFEFFFFFFFEFFFFFF00000000020000000000000000000000FDFFFFFF07000000FEFFFFFFFEFFFFFF0100000000000000FDFFFFFF02000000FEFFFFFF03000000FEFFFFFF0500000000000000030000000100000001000000010000000100000000000000FDFFFFFF0100000005000000FEFFFFFF0400000000000000FFFFFFFF0000000000000000000000000100000000000000FBFFFFFFFDFFFFFFFBFFFFFF03000000FFFFFFFF0300000003000000FEFFFFFF"> : tensor<1x50x3xi32>
    return %c : tensor<1x50x3xi32>
  }
}
