// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<2x3xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<2> : tensor<1x3x1xi64>
    %0:2 = call @inputs() : () -> (tensor<2x3xf32>, tensor<2x1x3xf32>)
    %1 = call @expected() : () -> tensor<2x3xf32>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1], index_vector_dim = 2>}> ({
    ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):
      %3 = stablehlo.minimum %arg0, %arg1 : tensor<f32>
      stablehlo.return %3 : tensor<f32>
    }) : (tensor<2x3xf32>, tensor<1x3x1xi64>, tensor<2x1x3xf32>) -> tensor<2x3xf32>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<2x3xf32>, tensor<2x3xf32>) -> ()
    return %2 : tensor<2x3xf32>
  }
  func.func private @inputs() -> (tensor<2x3xf32> {mhlo.layout_mode = "default"}, tensor<2x1x3xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[1.16928935, -2.78068614, -0.224639207], [-2.18083405, 0.61675769, -0.343673319]]> : tensor<2x3xf32>
    %cst_0 = stablehlo.constant dense<[[[5.44542122, 1.30949616, -5.498240e-02]], [[-0.00275761494, -3.964330e+00, -2.89312291]]]> : tensor<2x1x3xf32>
    return %cst, %cst_0 : tensor<2x3xf32>, tensor<2x1x3xf32>
  }
  func.func private @expected() -> (tensor<2x3xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[1.16928935, -2.78068614, -0.224639207], [-2.18083405, 0.61675769, -3.964330e+00]]> : tensor<2x3xf32>
    return %cst : tensor<2x3xf32>
  }
}
