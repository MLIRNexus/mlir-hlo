// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<8x9xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<8x9xf64>
    %1 = call @expected() : () -> tensor<8x9xf64>
    %2 = call @cumprod(%0) : (tensor<8x9xf64>) -> tensor<8x9xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<8x9xf64>, tensor<8x9xf64>) -> ()
    return %2 : tensor<8x9xf64>
  }
  func.func private @inputs() -> (tensor<8x9xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[0.96526778540036339, 2.4774937876332044, -4.326371476135404, 1.8914602397708764, 0.25062458961060646, 0.19401378393254332, -3.1198588034330461, -3.4421948367242603, -2.5306013454965814], [0.32693998065722452, 2.0844130929261491, 1.0618110708967237, -3.1823880073792106, 0.57470200694280404, 2.2399100524348698, 5.985015904683511, -1.6496255680999359, 4.1830107802845262], [2.655455769432201, 1.1132155572276439, -3.2902263319870375, -0.016064384569459626, -2.0177960897554472, -0.39126135762960523, 0.8475833158255609, -2.2469584450489717, 0.078415684958313026], [-5.655178313322816, 3.1277289456734252, 4.1615955284630495, 7.4278861324897711, -2.3301286420650933, 3.6753137948937695, -0.68958406424562291, -1.3221398280276169, -1.1453511403257379], [-2.2842685222856955, 1.2366161667722437, -2.1891891226751627, -0.56875046306245225, 5.3962192505971593, 1.3556682648564506, 0.70285079601154887, -2.2223945874351854, -0.43122344557148795], [1.3832708702427454, 7.2891697520486165, -2.2450899826326207, -1.3680089327551246, -0.92896555809563175, -5.1204270883785457, -0.55186196845621271, 0.79575716110181582, -6.5336062051381436], [2.981900636510642, -4.4765724335808494, -7.3036879061577133, 2.2223566010104006, -6.6338896119395798, 1.6933117297290847, -3.4106251997300303, -1.6539178512117902, -2.3422195349432453], [2.5240022929769124, 3.3822406426319751, 0.50426472033608227, 3.6741303683184414, -0.7082817858511844, -5.0066767370812819, -2.2497893142909069, -3.4304475935809213, 2.6188992899680841]]> : tensor<8x9xf64>
    return %cst : tensor<8x9xf64>
  }
  func.func private @expected() -> (tensor<8x9xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[0.96526778540036339, 2.4774937876332044, -4.326371476135404, 1.8914602397708764, 0.25062458961060646, 0.19401378393254332, -3.1198588034330461, -3.4421948367242603, -2.5306013454965814], [0.31558463108783674, 5.1641204885858478, -4.5937891301723726, -6.0193603834814429, 0.14403445463843217, 0.43457342494143059, -18.672404558913648, 5.678332613041924, -10.585532708814727], [0.83802102936632882, 5.7487792672917868, 15.114605959688969, 0.096697320062415881, -0.29063215935948677, -0.17003178823233148, -15.82641857048035, -12.758977418671545, -0.83007179801033359], [-4.739158351380925, 17.980623316595786, 62.900876576322567, 0.71825668274054388, 0.6772103188287667, -0.62492017686074397, 10.913646040284242, 16.869152210130643, 0.95072368040337119], [10.825510244186821, 22.235129481944309, -137.70191480761829, -0.40850882090638513, 3.6543753591668309, -0.84718445183859092, 7.6706648068020673, -37.489912566414638, -0.40997434124994786], [14.97461297629806, 162.07563325267287, 309.15318952391436, 0.55884371610919814, -3.3947888450193395, 4.3379462160474507, -4.2331481796495831, -29.832866393805407, 2.6786108999380818], [44.652807965523706, -725.5433119740751, -2257.9584114758968, 1.2419500214284589, 22.520654453702161, 7.3454952105670488, 14.437681855704174, 49.341110281531066, -6.2738947763468813], [112.70378969283956, -2453.9620777485275, -1138.6087668933978, 4.5630862896640405, -15.950969355005597, -36.776519993088009, -32.481742362094955, -169.26209302988912, -16.430698575109322]]> : tensor<8x9xf64>
    return %cst : tensor<8x9xf64>
  }
  func.func private @cumprod(%arg0: tensor<8x9xf64>) -> tensor<8x9xf64> {
    %cst = stablehlo.constant dense<1.000000e+00> : tensor<f64>
    %0 = "stablehlo.reduce_window"(%arg0, %cst) <{padding = dense<[[7, 0], [0, 0]]> : tensor<2x2xi64>, window_dimensions = array<i64: 8, 1>}> ({
    ^bb0(%arg1: tensor<f64>, %arg2: tensor<f64>):
      %1 = stablehlo.multiply %arg1, %arg2 : tensor<f64>
      stablehlo.return %1 : tensor<f64>
    }) : (tensor<8x9xf64>, tensor<f64>) -> tensor<8x9xf64>
    return %0 : tensor<8x9xf64>
  }
}
