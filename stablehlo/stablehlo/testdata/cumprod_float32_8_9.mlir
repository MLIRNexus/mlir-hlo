// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<8x9xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<8x9xf32>
    %1 = call @expected() : () -> tensor<8x9xf32>
    %2 = call @cumprod(%0) : (tensor<8x9xf32>) -> tensor<8x9xf32>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<8x9xf32>, tensor<8x9xf32>) -> ()
    return %2 : tensor<8x9xf32>
  }
  func.func private @inputs() -> (tensor<8x9xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[-4.06748676, -5.0641284, 3.01810288, -5.29881334, -2.62134647, -3.33453822, -2.40066385, -2.32606626, -4.14758253], [-1.43015432, 3.06664181, 6.17697525, -3.91404319, -4.76585245, -2.19035578, -2.0238266, -0.513878942, 1.56283605], [0.678435802, 1.12145138, -1.67962253, -1.767676, 4.41435432, 3.13634324, -1.88112414, -1.52071011, 1.91268492], [1.64711392, 2.07722068, -0.685546637, 1.8155396, 0.771368861, 1.70383573, 6.46541643, 3.71975327, 0.127090976], [-3.16805935, 3.96761632, 3.66452432, 3.06118298, 1.24790764, -3.40743542, -6.329400e+00, 4.32641459, -0.763047635], [-0.283004552, -0.481021255, -1.29166389, -2.07684779, 1.96155798, -2.29382038, -3.36473536, 3.06116676, 7.81926966], [-0.313505024, -13.720149, -0.0488562547, -3.53403044, 1.39930701, 3.44487691, -0.144204617, 8.77882862, 3.55740976], [3.49141359, -1.65513265, -0.885981321, 5.56268597, -4.8591814, 1.7360673, -2.22915959, 0.980064034, 3.10066438]]> : tensor<8x9xf32>
    return %cst : tensor<8x9xf32>
  }
  func.func private @expected() -> (tensor<8x9xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[-6.37931442, 1567.89319, -4.39815378, -8318.81445, -708.033875, 1824.43738, -404.531555, -770.459167, 103.698654], [1.56836748, -309.607697, -1.45725787, 1569.93896, 270.103149, -547.133484, 168.508209, 331.228363, -25.0021915], [-1.09664214, -100.959854, -0.235917732, -401.104156, -56.6746712, 249.792053, -83.2621689, -6.445650e+02, -15.997963], [-1.61642718, -90.0260467, 0.140458778, 226.910446, -12.8387232, 79.6443634, 44.2619209, 423.85791, -8.3641386], [-0.981369495, -43.3396683, -0.204885796, 124.982376, -16.6440754, 46.7441521, 6.84595108, 113.947853, -65.81221], [0.309769899, -10.9233513, -0.0559106134, 40.8281326, -13.3375874, -13.7182808, -1.08161128, 26.3377113, 86.2491531], [-1.09457564, 22.7086658, 0.0432857275, -1.965870e+01, -6.79948664, 5.98053836, 0.321455091, 8.60381412, 11.0303335], [3.49141359, -1.65513265, -0.885981321, 5.56268597, -4.8591814, 1.7360673, -2.22915959, 0.980064034, 3.10066438]]> : tensor<8x9xf32>
    return %cst : tensor<8x9xf32>
  }
  func.func private @cumprod(%arg0: tensor<8x9xf32>) -> tensor<8x9xf32> {
    %cst = stablehlo.constant dense<1.000000e+00> : tensor<f32>
    %0 = "stablehlo.reduce_window"(%arg0, %cst) <{padding = dense<[[0, 7], [0, 0]]> : tensor<2x2xi64>, window_dimensions = array<i64: 8, 1>}> ({
    ^bb0(%arg1: tensor<f32>, %arg2: tensor<f32>):
      %1 = stablehlo.multiply %arg1, %arg2 : tensor<f32>
      stablehlo.return %1 : tensor<f32>
    }) : (tensor<8x9xf32>, tensor<f32>) -> tensor<8x9xf32>
    return %0 : tensor<8x9xf32>
  }
}
