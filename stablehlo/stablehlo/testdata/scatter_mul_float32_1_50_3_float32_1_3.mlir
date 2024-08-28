// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<1x50x3xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<32> : tensor<1xi64>
    %0:2 = call @inputs() : () -> (tensor<1x50x3xf32>, tensor<1x3xf32>)
    %1 = call @expected() : () -> tensor<1x50x3xf32>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true}> ({
    ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):
      %3 = stablehlo.multiply %arg0, %arg1 : tensor<f32>
      stablehlo.return %3 : tensor<f32>
    }) : (tensor<1x50x3xf32>, tensor<1xi64>, tensor<1x3xf32>) -> tensor<1x50x3xf32>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<1x50x3xf32>, tensor<1x50x3xf32>) -> ()
    return %2 : tensor<1x50x3xf32>
  }
  func.func private @inputs() -> (tensor<1x50x3xf32> {mhlo.layout_mode = "default"}, tensor<1x3xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x8C7C1640CFA3623F9685F53F4EBA563F2580BABE89070ABE2C1BB93FE89AAE3D02FE87C069C386BFE6D1C9BFAE5696BF5BDFAA3FACD2703FE86B0B40E03BBEBD1D1E454040E78E3E63B12BBE1F2A814069E6D23F4297F4BEE306DD4049FE14C06AABBEBF20B78DBF898B98408B66CBC073465940C56D3AC0A46B92C0CBAEB43F545602C1198B38C004B0B7BF572247BFE78C2A3F7BF6613F9A7A4040B51DA4BF2DDB17400560D8BFB6F986BFD9D3773F4FE6593FBF7710409C6BB7C0921A3540259904C0F925C1BF2DE45AC0FF92593E8EC52E3F9E6C0240BFCEFD3F38BCB5BF7A83A63FF171FFBFF2D3CCBF8F9F0B401D8CF43F5CD88E3F11EECA3E40D9AF3FC488A0C0E35B0B4051D4B2BEE0D2C9BF0A14B3401EC3ADBF46D26EC0D68A9F40574A00BF9AAB2EC06E3D384065AC76BFAD932540859C7CBF193E3740899F4CC0DBD1CFBE089790BF79C24DC0A23D58C0FA1282BE8D51C1BFB2D161409CFD79409D9CC64050C85CBEE97FE53FEA442F4005F6B6409E3AD93F98513F404017D7BF019046BF5415B640CDBB893F03D61D40E756CA3E850975C06E2F47BF9E316FBF5B2CDCBF7825E83FE2E93C404ED6BDBE803EB63F5B6567C03ADBFDBF7EFB014075988640DBF28C40F8A8733F64AFB23F58DD6DBF3C132CC002948640C032E34065A35EBF2F2BAF3F09408AC0EF2B0EC0EEAD1C3FE889E13EBD3A59BF43572940810AA1C072E40D4056F78DC0AAFDC3BFB98F78BFE3BB47C0C2477B4069F099C0B2DF8A3F8DFA253E635C08C0E108AC3F1EF18B3F5FBE023F21CD1CC0654677C0951C40BFF18309401D643CBF794532407F54CB40BF0D12C0"> : tensor<1x50x3xf32>
    %cst_0 = stablehlo.constant dense<[[4.39728451, -0.296428502, 2.04568219]]> : tensor<1x3xf32>
    return %cst, %cst_0 : tensor<1x50x3xf32>, tensor<1x3xf32>
  }
  func.func private @expected() -> (tensor<1x50x3xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x8C7C1640CFA3623F9685F53F4EBA563F2580BABE89070ABE2C1BB93FE89AAE3D02FE87C069C386BFE6D1C9BFAE5696BF5BDFAA3FACD2703FE86B0B40E03BBEBD1D1E454040E78E3E63B12BBE1F2A814069E6D23F4297F4BEE306DD4049FE14C06AABBEBF20B78DBF898B98408B66CBC073465940C56D3AC0A46B92C0CBAEB43F545602C1198B38C004B0B7BF572247BFE78C2A3F7BF6613F9A7A4040B51DA4BF2DDB17400560D8BFB6F986BFD9D3773F4FE6593FBF7710409C6BB7C0921A3540259904C0F925C1BF2DE45AC0FF92593E8EC52E3F9E6C0240BFCEFD3F38BCB5BF7A83A63FF171FFBFF2D3CCBF8F9F0B401D8CF43F5CD88E3F11EECA3E40D9AF3FC488A0C0E35B0B4051D4B2BEE0D2C9BF0A14B3401EC3ADBF46D26EC0D68A9F40574A00BF9AAB2EC06E3D384065AC76BFAD932540859C7CBF193E3740899F4CC0DBD1CFBE089790BF79C24DC0A23D58C0FA1282BE8D51C1BFB2D161409CFD79409D9CC64050C85CBEE97FE53FEA442F4005F6B6409E3AD93F98513F404017D7BFB2485AC013E6D7BF2CE10C4003D61D40E756CA3E850975C06E2F47BF9E316FBF5B2CDCBF7825E83FE2E93C404ED6BDBE803EB63F5B6567C03ADBFDBF7EFB014075988640DBF28C40F8A8733F64AFB23F58DD6DBF3C132CC002948640C032E34065A35EBF2F2BAF3F09408AC0EF2B0EC0EEAD1C3FE889E13EBD3A59BF43572940810AA1C072E40D4056F78DC0AAFDC3BFB98F78BFE3BB47C0C2477B4069F099C0B2DF8A3F8DFA253E635C08C0E108AC3F1EF18B3F5FBE023F21CD1CC0654677C0951C40BFF18309401D643CBF794532407F54CB40BF0D12C0"> : tensor<1x50x3xf32>
    return %cst : tensor<1x50x3xf32>
  }
}
