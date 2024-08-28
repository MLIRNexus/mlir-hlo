// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<6x4xui64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<2x3xui64>, tensor<ui64>)
    %1 = call @expected() : () -> tensor<6x4xui64>
    %2 = stablehlo.pad %0#0, %0#1, low = [1, 0], high = [2, 1], interior = [1, 0] : (tensor<2x3xui64>, tensor<ui64>) -> tensor<6x4xui64>
    stablehlo.custom_call @check.expect_eq(%2, %1) {has_side_effect = true} : (tensor<6x4xui64>, tensor<6x4xui64>) -> ()
    return %2 : tensor<6x4xui64>
  }
  func.func private @inputs() -> (tensor<2x3xui64> {mhlo.layout_mode = "default"}, tensor<ui64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<0> : tensor<2x3xui64>
    %c_0 = stablehlo.constant dense<0> : tensor<ui64>
    return %c, %c_0 : tensor<2x3xui64>, tensor<ui64>
  }
  func.func private @expected() -> (tensor<6x4xui64> {mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<0> : tensor<6x4xui64>
    return %c : tensor<6x4xui64>
  }
}
