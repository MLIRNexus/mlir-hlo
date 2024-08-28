// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xi64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<20x20xi64>, tensor<20x20xi64>)
    %1 = call @expected() : () -> tensor<20x20xi64>
    %2 = stablehlo.minimum %0#0, %0#1 : tensor<20x20xi64>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<20x20xi64>, tensor<20x20xi64>) -> ()
    return %2 : tensor<20x20xi64>
  }
  func.func private @inputs() -> (tensor<20x20xi64> {mhlo.layout_mode = "default"}, tensor<20x20xi64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0xFBFFFFFFFFFFFFFF000000000000000002000000000000000100000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF06000000000000000300000000000000FCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000FBFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFFF9FFFFFFFFFFFFFF040000000000000001000000000000000400000000000000000000000000000004000000000000000100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF040000000000000001000000000000000000000000000000FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0100000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03000000000000000300000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000000000000000000001000000000000000200000000000000FBFFFFFFFFFFFFFF03000000000000000100000000000000000000000000000001000000000000000300000000000000F9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000FCFFFFFFFFFFFFFF0000000000000000000000000000000002000000000000000100000000000000020000000000000002000000000000000200000000000000030000000000000002000000000000000000000000000000FFFFFFFFFFFFFFFF00000000000000000100000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF000000000000000000000000000000000700000000000000FEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF010000000000000000000000000000000300000000000000FFFFFFFFFFFFFFFF02000000000000000100000000000000FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF02000000000000000200000000000000000000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF000000000000000002000000000000000000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF0200000000000000FEFFFFFFFFFFFFFF03000000000000000100000000000000FFFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF02000000000000000000000000000000FBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFF000000000000000004000000000000000100000000000000FFFFFFFFFFFFFFFF000000000000000002000000000000000000000000000000010000000000000000000000000000000200000000000000FFFFFFFFFFFFFFFF0600000000000000FEFFFFFFFFFFFFFF0200000000000000030000000000000001000000000000000000000000000000FFFFFFFFFFFFFFFF010000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF02000000000000000600000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000020000000000000003000000000000000300000000000000FCFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF000000000000000002000000000000000100000000000000010000000000000003000000000000000000000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF010000000000000001000000000000000500000000000000FEFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0100000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFF0000000000000000020000000000000001000000000000000000000000000000030000000000000000000000000000000600000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0100000000000000040000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF030000000000000003000000000000000000000000000000FEFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF02000000000000000000000000000000FFFFFFFFFFFFFFFF0100000000000000000000000000000001000000000000000100000000000000FCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF040000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF040000000000000006000000000000000100000000000000FCFFFFFFFFFFFFFF01000000000000000200000000000000040000000000000001000000000000000000000000000000FFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF01000000000000000300000000000000FDFFFFFFFFFFFFFF0000000000000000050000000000000004000000000000000A000000000000000000000000000000FEFFFFFFFFFFFFFF0000000000000000FBFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF00000000000000000200000000000000050000000000000003000000000000000200000000000000FFFFFFFFFFFFFFFF0000000000000000000000000000000000000000000000000000000000000000070000000000000003000000000000000300000000000000FEFFFFFFFFFFFFFF0200000000000000FDFFFFFFFFFFFFFF0000000000000000040000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000FAFFFFFFFFFFFFFF04000000000000000200000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF00000000000000000100000000000000FFFFFFFFFFFFFFFF0200000000000000FDFFFFFFFFFFFFFF0000000000000000030000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF03000000000000000100000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000030000000000000000000000000000000100000000000000000000000000000001000000000000000300000000000000020000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000000000000000000000000000000000000200000000000000FEFFFFFFFFFFFFFF0200000000000000FDFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF000000000000000001000000000000000300000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF000000000000000001000000000000000300000000000000FDFFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0300000000000000010000000000000000000000000000000400000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FBFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000FCFFFFFFFFFFFFFF0400000000000000FEFFFFFFFFFFFFFF0900000000000000FEFFFFFFFFFFFFFF030000000000000000000000000000000200000000000000FCFFFFFFFFFFFFFF05000000000000000000000000000000FDFFFFFFFFFFFFFF01000000000000000600000000000000FEFFFFFFFFFFFFFF01000000000000000100000000000000FDFFFFFFFFFFFFFF03000000000000000400000000000000F9FFFFFFFFFFFFFF01000000000000000000000000000000060000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000000000000000000001000000000000000300000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF040000000000000003000000000000000300000000000000FEFFFFFFFFFFFFFF050000000000000003000000000000000000000000000000FFFFFFFFFFFFFFFF04000000000000000200000000000000000000000000000002000000000000000100000000000000FFFFFFFFFFFFFFFF0500000000000000FBFFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFF07000000000000000100000000000000FFFFFFFFFFFFFFFF"> : tensor<20x20xi64>
    %c_0 = stablehlo.constant dense<"0x0100000000000000FEFFFFFFFFFFFFFF030000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF07000000000000000000000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFF01000000000000000400000000000000FEFFFFFFFFFFFFFF020000000000000000000000000000000400000000000000000000000000000001000000000000000000000000000000FAFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF02000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF020000000000000003000000000000000300000000000000020000000000000004000000000000000100000000000000000000000000000001000000000000000500000000000000FEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF000000000000000002000000000000000100000000000000FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF040000000000000001000000000000000000000000000000FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF02000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF030000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0000000000000000020000000000000001000000000000000100000000000000000000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF010000000000000000000000000000000200000000000000000000000000000001000000000000000100000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0400000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0100000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03000000000000000200000000000000020000000000000000000000000000000600000000000000FFFFFFFFFFFFFFFF000000000000000000000000000000000100000000000000FBFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFF0100000000000000FCFFFFFFFFFFFFFF01000000000000000200000000000000FFFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF03000000000000000300000000000000FFFFFFFFFFFFFFFF03000000000000000100000000000000F7FFFFFFFFFFFFFF0300000000000000FDFFFFFFFFFFFFFF04000000000000000400000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF04000000000000000000000000000000FFFFFFFFFFFFFFFF03000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF02000000000000000100000000000000000000000000000001000000000000000200000000000000000000000000000003000000000000000200000000000000FEFFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000FBFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF000000000000000000000000000000000400000000000000FDFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0200000000000000FCFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF01000000000000000300000000000000FEFFFFFFFFFFFFFF0200000000000000010000000000000003000000000000000000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF020000000000000001000000000000000000000000000000FEFFFFFFFFFFFFFF00000000000000000200000000000000050000000000000000000000000000000200000000000000FCFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFF01000000000000000100000000000000000000000000000000000000000000000300000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF000000000000000002000000000000000A0000000000000000000000000000000200000000000000FEFFFFFFFFFFFFFF000000000000000006000000000000000000000000000000FDFFFFFFFFFFFFFF04000000000000000100000000000000030000000000000000000000000000000200000000000000010000000000000000000000000000000100000000000000FEFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF0100000000000000030000000000000002000000000000000000000000000000010000000000000002000000000000000100000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF02000000000000000000000000000000040000000000000000000000000000000000000000000000020000000000000004000000000000000200000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0400000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0300000000000000FFFFFFFFFFFFFFFF000000000000000002000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF010000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000300000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF0400000000000000040000000000000000000000000000000200000000000000030000000000000007000000000000000100000000000000FEFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000040000000000000000000000000000000300000000000000010000000000000001000000000000000200000000000000010000000000000001000000000000000100000000000000F6FFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01000000000000000100000000000000040000000000000003000000000000000000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0300000000000000FCFFFFFFFFFFFFFF04000000000000000300000000000000FFFFFFFFFFFFFFFFF9FFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFF0000000000000000000000000000000000000000000000000400000000000000FCFFFFFFFFFFFFFF00000000000000000000000000000000FCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF040000000000000001000000000000000000000000000000FDFFFFFFFFFFFFFF0100000000000000040000000000000003000000000000000000000000000000F9FFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000FFFFFFFFFFFFFFFF00000000000000000400000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF0000000000000000F8FFFFFFFFFFFFFF00000000000000000500000000000000FFFFFFFFFFFFFFFF00000000000000000100000000000000FFFFFFFFFFFFFFFF0300000000000000FEFFFFFFFFFFFFFF0000000000000000FAFFFFFFFFFFFFFF04000000000000000000000000000000020000000000000001000000000000000200000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000FCFFFFFFFFFFFFFF02000000000000000000000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF030000000000000005000000000000000600000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF030000000000000005000000000000000000000000000000050000000000000001000000000000000200000000000000FDFFFFFFFFFFFFFF"> : tensor<20x20xi64>
    return %c, %c_0 : tensor<20x20xi64>, tensor<20x20xi64>
  }
  func.func private @expected() -> (tensor<20x20xi64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0xFBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF02000000000000000000000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0100000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFF9FFFFFFFFFFFFFF020000000000000000000000000000000400000000000000000000000000000001000000000000000000000000000000FAFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF02000000000000000000000000000000FDFFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0100000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF00000000000000000200000000000000FBFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF01000000000000000100000000000000F9FFFFFFFFFFFFFFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF02000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF00000000000000000200000000000000FEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF000000000000000001000000000000000000000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF02000000000000000000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFBFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF0100000000000000FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF0100000000000000FCFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF00000000000000000100000000000000F7FFFFFFFFFFFFFF0200000000000000FDFFFFFFFFFFFFFF0400000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000020000000000000000000000000000000300000000000000FCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0200000000000000FBFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0100000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0100000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF000000000000000001000000000000000000000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0100000000000000FCFFFFFFFFFFFFFF00000000000000000000000000000000FCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFAFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF00000000000000000100000000000000FCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF000000000000000005000000000000000000000000000000FDFFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF020000000000000001000000000000000000000000000000FCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0200000000000000FFFFFFFFFFFFFFFF01000000000000000000000000000000FFFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0200000000000000000000000000000004000000000000000000000000000000FEFFFFFFFFFFFFFF0000000000000000FBFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0400000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FAFFFFFFFFFFFFFF04000000000000000200000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF00000000000000000100000000000000FEFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFF0000000000000000030000000000000000000000000000000000000000000000FFFFFFFFFFFFFFFF01000000000000000100000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000F6FFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01000000000000000100000000000000020000000000000000000000000000000000000000000000FDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0200000000000000FCFFFFFFFFFFFFFF00000000000000000200000000000000FEFFFFFFFFFFFFFFF9FFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFF0000000000000000FDFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF030000000000000001000000000000000000000000000000FDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000F9FFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFF0100000000000000FEFFFFFFFFFFFFFF030000000000000000000000000000000000000000000000FCFFFFFFFFFFFFFF02000000000000000000000000000000FDFFFFFFFFFFFFFF00000000000000000400000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFFFFFFFFFF0000000000000000F8FFFFFFFFFFFFFF00000000000000000000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000FAFFFFFFFFFFFFFF0300000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FEFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFF0200000000000000FEFFFFFFFFFFFFFFFDFFFFFFFFFFFFFFFEFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0400000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000FCFFFFFFFFFFFFFFFCFFFFFFFFFFFFFF0300000000000000FBFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF01000000000000000100000000000000FDFFFFFFFFFFFFFF"> : tensor<20x20xi64>
    return %c : tensor<20x20xi64>
  }
}
