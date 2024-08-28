// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xi16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<20x20xi16>, tensor<20x20xi16>)
    %1 = call @expected() : () -> tensor<20x20xi16>
    %2 = stablehlo.maximum %0#0, %0#1 : tensor<20x20xi16>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<20x20xi16>, tensor<20x20xi16>) -> ()
    return %2 : tensor<20x20xi16>
  }
  func.func private @inputs() -> (tensor<20x20xi16> {mhlo.layout_mode = "default"}, tensor<20x20xi16> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0xFEFFFDFF0000FEFF0200FBFFFAFFFEFF02000300000000000200FFFF0000FFFFFEFF0000FFFF0300FCFF020002000500FCFF0000FEFF00000000FFFFFCFF0000020000000200FDFF0000FFFF0000FFFF0000FFFF02000100000004000500010000000200FBFF07000300FFFF0300000000000000FFFF0000FFFFFDFFFCFF0000F6FF00000000FDFF0500FAFFFFFFFDFF0000FDFF0000020006000600FFFF040002000400FFFFFFFF040000000000040001000000FFFFFFFF0000FEFF0000FCFF010000000400FDFF0400000001000000040003000000040000000200FCFF06000000FDFF05000100FEFF020000000000FDFFFFFF05000000000002000500FEFF0000FEFF0000FFFF010000000400FEFF0500010002000000FEFFFEFFFFFF000002000100FFFF050003000400FCFF000005000100FCFFFEFFFDFF00000000FEFF0000FFFFFDFFFFFFFAFF020000000000FFFF01000000FFFF0100040000000100FDFF020000000100F9FFFDFF0000000001000000FFFFFDFF02000200000000000200FFFFFDFFFDFF0000FCFF0000FFFF07000000FDFF0200FCFF000002000100010005000300020002000700FBFFFDFF00000700FFFF060000000300FEFF00000200FDFFFEFFFEFFFFFFFCFFFFFF0200FEFF060000000000FCFF010000000600FFFF020002000300FDFF05000100FEFF00000200FFFFFBFFFFFFFDFFFDFFF5FFFEFFFFFFFCFFFFFF0100FCFFFEFFFCFF0000020004000100F9FF0100FCFF0200FFFFFFFF0000FDFF0100020000000300FFFF00000000030000000300060000000000000001000400000004000500FBFFFFFFFCFF000002000000FDFF010002000200FEFF000002000300FDFF0000FDFF010004000100FFFF0200FFFFFDFF000003000200FFFF04000100FFFF0500FEFF02000000030002000200FCFF01000100FAFF02000100FFFF000001000500FEFFFFFF0100020003000000FEFF0300010002000000000002000400FEFF020006000000FFFFFFFF01000000FFFF000000000700FEFF0200FEFF0000000003000500FFFFFFFF0100FEFF00000400FBFF0100010000000000000001000300FBFFFEFFFFFFFFFFFCFFFDFFFCFF0000FDFF0000"> : tensor<20x20xi16>
    %c_0 = stablehlo.constant dense<"0xFDFFFEFF000000000200FFFF0000FBFF0100000001000200FEFFFDFFFDFF030002000100FFFF0300F8FFFBFF02000300F9FFF8FF060000000000000001000100FCFFFFFFFBFFFDFF0000FFFF01000300FFFF0300000006000300000000000000FEFF01000100FEFF05000000030004000400000000000400050004000000FEFF0400FFFFFEFF0000FFFF0200010000000000000002000000FEFF0500FEFF0000FEFF020003000100FAFF02000500000003000400FCFFFDFFFEFFFAFF010004000000FEFF000000000000030001000100040001000100F9FF0000FEFFFEFF00000000FEFFFCFF0200000002000300FEFF0000FFFF0000040001000000030003000100FFFF0100FAFF0000010001000100FEFF000000000300FBFFFEFF0400FEFF00000600FEFFFEFFFDFF0200000003000400FDFF01000000FFFF040005000000000008000200FEFFFFFF0600FDFFFEFFFFFFFFFF0000FCFFFCFF06000100FEFFFFFFFEFF000006000100FEFF04000400020001000200FDFFFFFF01000500000000000200FCFF01000400000002000200FEFF0100FDFF0200FFFF030000000200FBFF0200FCFFFCFFFFFF000002000000FDFF020002000000020000000400FDFF01000500FFFFFEFFFFFF00000100FEFFFFFFFFFF0200FEFF02000300FAFFFFFF01000400050002000000010000000000FFFF0300FBFFFDFF01000500FEFF0400FEFF02000100FFFFFFFF0000FEFF0000FBFFFDFFFDFF0000FDFF0000FEFF040000000100030001000000FDFFFFFF0300FCFFFFFF0000FDFF050001000200FCFF0000000004000000FDFF00000000FFFFFFFF04000100FEFF01000200040000000200000000000000FCFFFEFF010002000300000002000100030004000000010001000000FCFFFBFF000000000400FEFFFDFFFCFFFFFF0300000002000000FAFFFFFF01000200FFFF0000FFFFFEFF03000000FFFF010000000500FDFFFFFF000000000300FAFFFDFFFCFF02000000FFFFFFFF0100000001000600FFFF0000FEFF0000FFFFFFFFFFFF000001000400FEFF0000050002000000010001000100000000000600010000000100FDFFFFFF0000030004000000FEFFFEFFFFFFFBFF0100"> : tensor<20x20xi16>
    return %c, %c_0 : tensor<20x20xi16>, tensor<20x20xi16>
  }
  func.func private @expected() -> (tensor<20x20xi16> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<"0xFEFFFEFF000000000200FFFF0000FEFF02000300010002000200FFFF0000030002000100FFFF0300FCFF020002000500FCFF0000060000000000000001000100020000000200FDFF0000FFFF0100030000000300020006000300040005000100000002000100070005000000030004000400000000000400050004000000000004000000000000000500020001000000000000000200020006000600FFFF04000200040003000100040002000500040003000400FFFFFFFF0000FEFF0100040001000000040000000400030001000100040003000100040000000200FEFF06000000FEFF0500020000000200030000000000FFFF0500040001000200050003000100FFFF0100FFFF01000100040001000500010002000300FEFFFEFF0400000002000600FFFF050003000400000003000500010001000000FFFF040005000000000008000200FFFFFFFF060000000000FFFF01000000FFFF0100060001000100FFFF0200000006000100FEFF04000400020001000200FDFF020002000500000002000200FDFF0100040000000200020007000100FDFF0200FFFF030002000200010005000300020002000700020000000000070002000600020003000400000002000500FFFFFEFFFFFF000001000200FFFF06000200000002000300000006000100040005000300000005000100000000000300FFFFFDFF01000500FEFF0400FEFF02000100FFFF01000000FEFF00000000020004000100FDFF0100FEFF040000000100030001000100020000000300FFFF00000000030005000300060000000000000004000400000004000500FFFFFFFF040001000200010002000400020002000000000002000300FEFF010002000300040002000100030004000000010003000200FFFF0400010000000500FEFF02000000030003000200020001000100FFFF02000200FFFF000001000500030000000100020003000500FEFF030001000200030000000200040002000200060000000100000001000600FFFF000000000700FFFF0200FFFF000001000400050000000500020000000100040001000100010006000100000001000300FFFF0000030004000000FEFFFEFF0000FDFF0100"> : tensor<20x20xi16>
    return %c : tensor<20x20xi16>
  }
}
