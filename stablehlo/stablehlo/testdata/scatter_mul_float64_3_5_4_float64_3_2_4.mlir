// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<3x5x4xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<1> : tensor<2x1xi64>
    %0:2 = call @inputs() : () -> (tensor<3x5x4xf64>, tensor<3x2x4xf64>)
    %1 = call @expected() : () -> tensor<3x5x4xf64>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 2], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1], index_vector_dim = 1>}> ({
    ^bb0(%arg0: tensor<f64>, %arg1: tensor<f64>):
      %3 = stablehlo.multiply %arg0, %arg1 : tensor<f64>
      stablehlo.return %3 : tensor<f64>
    }) : (tensor<3x5x4xf64>, tensor<2x1xi64>, tensor<3x2x4xf64>) -> tensor<3x5x4xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<3x5x4xf64>, tensor<3x5x4xf64>) -> ()
    return %2 : tensor<3x5x4xf64>
  }
  func.func private @inputs() -> (tensor<3x5x4xf64> {mhlo.layout_mode = "default"}, tensor<3x2x4xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[[2.3896052026937022, 1.6694553302637636, 5.9578578279859364, 1.8321092720579022], [2.8366819652114752, -0.65864113290753334, -2.1954730261592128, -2.8526460473609494], [-0.95382348343094381, -1.5427021403099006, 1.7963859195157137, 4.0727416940639083], [-1.7623936874786148, 0.91196197160913206, 2.9429968087507601, -6.7753150424327453], [2.3314627902001956, 3.415945808836466, -1.6411520050271728, 1.16178543807012]], [[0.28041216628422544, -0.0046811473313141203, -0.51788284195775536, 2.962313257111703], [-2.28225655541699, -1.0344079471033174, -1.1130722774300328, -1.9986076356772879], [0.3343917278079892, 1.0106820738354196, 0.38916876121187499, -3.3074027081674489], [1.0144174448202881, -0.10765073676620897, 2.1471008497690329, -1.9192641943289503], [2.0145753982313375, -2.907377017692867, -2.015790560428413, 2.8151836100426335]], [[-6.2644853718471118, -1.0156514572140658, -1.2567601466820686, -2.1825225389020537], [1.3951373355455017, -0.9782821165381077, -3.2892499564373963, 6.0237822036770989], [-3.2690320193181113, -2.00047959434671, 5.4535221569479475, -0.7001466580365806], [1.0177335873653821, 1.7825362671262188, 4.3984861102526729, -0.6448751167937018], [-0.49267177114778904, -0.21528145330073312, 2.5492270388851295, 1.7192723005361104]]]> : tensor<3x5x4xf64>
    %cst_0 = stablehlo.constant dense<[[[1.428321230494735, -0.42839111890587189, -5.5430119833861609, -4.4048149912654502], [4.1449547150391952, -0.45091630137429256, 2.6169752994685123, 2.864975294476142]], [[2.9519874902834564, -3.7445437489704467, 1.2297758405714454, -1.9525729725208585], [-1.9291842750873547, 3.3928742017294322, -0.17851714599481103, 4.6557069373342728]], [[-0.93833898160809714, -0.83811684502279227, -0.95007199658786579, -1.4730545409111842], [-0.037245440293364435, -2.582995354728598, -2.1002818374553023, -1.7885152149313197]]]> : tensor<3x2x4xf64>
    return %cst, %cst_0 : tensor<3x5x4xf64>, tensor<3x2x4xf64>
  }
  func.func private @expected() -> (tensor<3x5x4xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[[2.3896052026937022, 1.6694553302637636, 5.9578578279859364, 1.8321092720579022], [16.794084315415809, -0.1272287452891141, 31.847368034368273, 35.999497748305529], [-0.95382348343094381, -1.5427021403099006, 1.7963859195157137, 4.0727416940639083], [-1.7623936874786148, 0.91196197160913206, 2.9429968087507601, -6.7753150424327453], [2.3314627902001956, 3.415945808836466, -1.6411520050271728, 1.16178543807012]], [[0.28041216628422544, -0.0046811473313141203, -0.51788284195775536, 2.962313257111703], [12.997286410322907, 13.141910795595775, 0.2443595170551166, 18.16855763003166], [0.3343917278079892, 1.0106820738354196, 0.38916876121187499, -3.3074027081674489], [1.0144174448202881, -0.10765073676620897, 2.1471008497690329, -1.9192641943289503], [2.0145753982313375, -2.907377017692867, -2.015790560428413, 2.8151836100426335]], [[-6.2644853718471118, -1.0156514572140658, -1.2567601466820686, -2.1825225389020537], [0.048758443396792361, -2.1178359157590165, -6.5634317230059276, 15.870138882135855], [-3.2690320193181113, -2.00047959434671, 5.4535221569479475, -0.7001466580365806], [1.0177335873653821, 1.7825362671262188, 4.3984861102526729, -0.6448751167937018], [-0.49267177114778904, -0.21528145330073312, 2.5492270388851295, 1.7192723005361104]]]> : tensor<3x5x4xf64>
    return %cst : tensor<3x5x4xf64>
  }
}
