// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<1x2x3xf16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<0> : tensor<1xi64>
    %0:2 = call @inputs() : () -> (tensor<1x2x3xf16>, tensor<2x3xf16>)
    %1 = call @expected() : () -> tensor<1x2x3xf16>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [0], scatter_dims_to_operand_dims = [0]>, unique_indices = true}> ({
    ^bb0(%arg0: tensor<f16>, %arg1: tensor<f16>):
      %3 = stablehlo.minimum %arg0, %arg1 : tensor<f16>
      stablehlo.return %3 : tensor<f16>
    }) : (tensor<1x2x3xf16>, tensor<1xi64>, tensor<2x3xf16>) -> tensor<1x2x3xf16>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<1x2x3xf16>, tensor<1x2x3xf16>) -> ()
    return %2 : tensor<1x2x3xf16>
  }
  func.func private @inputs() -> (tensor<1x2x3xf16> {mhlo.layout_mode = "default"}, tensor<2x3xf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[[-3.230470e+00, 1.150390e+00, -1.958980e+00], [1.332030e+00, 2.011720e+00, 2.570310e+00]]]> : tensor<1x2x3xf16>
    %cst_0 = stablehlo.constant dense<[[5.004880e-01, -1.803710e+00, -1.993410e-01], [-3.781250e+00, -6.421880e+00, -4.214840e+00]]> : tensor<2x3xf16>
    return %cst, %cst_0 : tensor<1x2x3xf16>, tensor<2x3xf16>
  }
  func.func private @expected() -> (tensor<1x2x3xf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[[-3.230470e+00, -1.803710e+00, -1.958980e+00], [-3.781250e+00, -6.421880e+00, -4.214840e+00]]]> : tensor<1x2x3xf16>
    return %cst : tensor<1x2x3xf16>
  }
}
