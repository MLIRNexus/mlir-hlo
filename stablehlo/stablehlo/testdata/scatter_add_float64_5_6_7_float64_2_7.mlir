// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<5x6x7xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<[[0, 1], [2, 3]]> : tensor<2x2xi64>
    %0:2 = call @inputs() : () -> (tensor<5x6x7xf64>, tensor<2x7xf64>)
    %1 = call @expected() : () -> tensor<5x6x7xf64>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [1], inserted_window_dims = [0, 1], scatter_dims_to_operand_dims = [0, 1], index_vector_dim = 1>, unique_indices = true}> ({
    ^bb0(%arg0: tensor<f64>, %arg1: tensor<f64>):
      %3 = stablehlo.add %arg0, %arg1 : tensor<f64>
      stablehlo.return %3 : tensor<f64>
    }) : (tensor<5x6x7xf64>, tensor<2x2xi64>, tensor<2x7xf64>) -> tensor<5x6x7xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<5x6x7xf64>, tensor<5x6x7xf64>) -> ()
    return %2 : tensor<5x6x7xf64>
  }
  func.func private @inputs() -> (tensor<5x6x7xf64> {mhlo.layout_mode = "default"}, tensor<2x7xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x5C7063C6DAB1F93FCB1AA35143BFD33FA78F23189266DCBF5229BF32CFDEF93F24B31D30F66018C05FD06F65D97E16407104599074A414C0A8310616A61CCA3FD662AD2C8EA5EB3F4AB7BA1320570740CAF104405ED9F2BF3D07E525DE721A4024BF4D4DE93F12C03AE49EDB33BBFD3FB269DDA48BA71C400549B809A2331540A9594F0FACD6F83F00CE5B02E8131940C46DEA245BE90FC0BD8417D0157D02C05A6B1957F52CFC3FEC0FB80091D1F7BF7F453919D434ECBFE883262735D60BC0FC4A532E6F34F9BF4386ACA152A200406E15CB89DF15F1BF0D73393E977712C03418B7E817B405C0425A7A1F41EEE03FD00CF2FF98B2CE3FDFDF3574D31CF73FAFDB3B96C1ABF0BFC4450E431835EABF9EC08248BE62EABFC24480206A510940E142A414327F02C08EFB01CCBE44FFBF4E09CF9DECDF064054EEBFCF71A000C03D6E81D41D5100C024AF92805D34FABF3187B6C53FF417C04369C11036A7024009B3829FC68122404FF890EFB46D05C080D2C2935ABF99BFBA8703E6A8420AC070E363949659E9BF2205A88D7120EFBFFB84BFF5C556E1BFA84313509A81F7BFAE37046B89EFBC3FFB7599618814F63F231D1E592D11F3BF978EAD286FF2FABF132561754447CD3FAE5DBB7D6A7407C063BE0671677D20C069EDFD03D0040EC07F6C3BAC302E1040C0CBA057EFEE0CC0B6B11631770BF93F701645F5B96A0FC01F96741C8DADD23F439DAACDA15EF6BFC35E242BACEB10C09A3207523CACF33FBFB2E28D18430F40246DA3BFE9BAFA3F381B77A5B96B0BC0962F53ECC2071140868AAAB0CFB2FD3FC4A0E752ABBD0440D0A2772CC39110C08C00B577F587E83F6251FAE246B6F9BF339827F5543D154088A395306C690FC0734B98B7AF7010404E7009C4A933F8BFEC412F1C86A01EC014F00A60B786F43FDAE3F51366C613C0222E979365A2CEBFB2A0383951A3E03F35C8F74E43E401C0D0F9E0009AC311C0DCF47DAD878ADD3FFF9A2BD7AC7FC8BF8A0D9D0FBDF5FFBFB218F12CAB0121C036511A7CC959FABFE7B241CC108618C07C8480B256A9FD3FDC64C213CEAA0BC0D8AFC97447DAF33F14B19E25A3FC14C002A5A64695E302C0989706206CF0FDBFCC9593C510F303C0F58391618DF803C0342AB62CB4761240908AC83FB3991540A9CEFE61C86510C0AC5302727B61E13F7E68567411E7CE3F302B27C09C6D0A40564D1AB4540010C03F706910ACEB02C09E0C2608F8AC0340B69391464F1FF33F9E72027E987F00C02AFF5F1D214E1FC0643F1F7797800D408AD92DA0A1EC1940FAEE6AAB94170BC018435826B0D41C40E21DD5464D74B1BF8CB98D228F74D7BF2CCC5CF40EA009C0BE30850A6B3906C0B665F3BB5C070BC0937F48F072B310406B3717D701EF0A40152AC54907A408C04F05043B270D0640E48D51D4E0B2F93FDB23F58FBB62F13FC133ABE9377A00405F8EE015B39AB1BF7C216CF488FB01C0D476D9909AA806408026EE39C8F117C0C21BF1E0AEA7004077F75F08350FF83FEC82F37F1959F6BF48CE02E14C870040536A430B81BAF8BF82F57E356ABF05407E24C209D539EF3F5D973624FDC6C93F5E72371EEDC8E83F4CE0EC5237F00940FC287981A40FF8BFFC74AA5E52160AC018F9BC172B22F33F05372716C97F00C0B6BC1FD420681440C926709A397A02C0A88BEC7C2076E63FD8337A4D675E03C0EE67DE94C0210F40DC6E3AAA9C0011403E1EDA6D59F409C03468D09C8149B1BFC57C093A91670640F16CFAC0A5A6C73F9218671A63660AC014A9F738E74B07C0DE743BA121B41140F1F6FD51B718E2BFAA13750342E0EB3F86F12059843712C0328A7CCAA891FABF8A38514FED42E03F156D1BAFEB82024092A7E0D05E98E63FB3A1BA703FCD084048ECEB94459D0D404AB81A5304DBA03F93702347446406406726F0F72577F3BF4E9B4CF2149A19C0BFE53E5FC5F70AC0EF85A2E8472AFEBF0E3848C38022F1BF7E2C534FDB08F6BF2852B5A238A9F33FCB02649D8EF7D63FC155AF8F8EA8FEBF524646F27DEEF53F5640BB941A8F0340E6A9C6852CB711C09854D0D0ECA606C0C30097DC083E0540C7F7B65B8635F8BF637B4E8938F4D9BF2B72F38C40A4FBBF54A3F49A0EB000C0EAAB4ADAE8BC853F33815DED4EF912C04A85FF4478B41140FFA978A331D316C0E18092881B3F05C04E242074D1C0124072227BD10529DABFB46748FE0BDDEB3F669966E3A5020340244B7625042EF53FCB4BC123C181DEBF1B3B4246836E064064A98F0594EAF23FA068D91F4BEE0F401647BFF26D6DF23FDEE94A532075E53F5D109D89695EFFBF6E1A4527BC6E1AC0E8C6567B3526F93F5A7B409AD2DC0440"> : tensor<5x6x7xf64>
    %cst_0 = stablehlo.constant dense<[[0.76198700036790146, 0.075645346574358382, -3.2109221500789471, -3.0982430876739047, -7.7554341908477821, -2.5631487095427556, -3.7363458021690805], [-0.4284612040185054, 2.7219368821802221, -1.7378103844152855, 0.90062290967997349, -3.0375741105143206, 3.232190769663954, -0.094657271187703118]]> : tensor<2x7xf64>
    return %cst, %cst_0 : tensor<5x6x7xf64>, tensor<2x7xf64>
  }
  func.func private @expected() -> (tensor<5x6x7xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x5C7063C6DAB1F93FCB1AA35143BFD33FA78F23189266DCBF5229BF32CFDEF93F24B31D30F66018C05FD06F65D97E16407104599074A414C0A06153155CE9EE3FB797E1F63D11EE3FF8195000BFC6D2BFC0B40366F11A11C0186EEB91C94AF2BF60D4765B93801CC0FAEA8EADDE0CFEBFB269DDA48BA71C400549B809A2331540A9594F0FACD6F83F00CE5B02E8131940C46DEA245BE90FC0BD8417D0157D02C05A6B1957F52CFC3FEC0FB80091D1F7BF7F453919D434ECBFE883262735D60BC0FC4A532E6F34F9BF4386ACA152A200406E15CB89DF15F1BF0D73393E977712C03418B7E817B405C0425A7A1F41EEE03FD00CF2FF98B2CE3FDFDF3574D31CF73FAFDB3B96C1ABF0BFC4450E431835EABF9EC08248BE62EABFC24480206A510940E142A414327F02C08EFB01CCBE44FFBF4E09CF9DECDF064054EEBFCF71A000C03D6E81D41D5100C024AF92805D34FABF3187B6C53FF417C04369C11036A7024009B3829FC68122404FF890EFB46D05C080D2C2935ABF99BFBA8703E6A8420AC070E363949659E9BF2205A88D7120EFBFFB84BFF5C556E1BFA84313509A81F7BFAE37046B89EFBC3FFB7599618814F63F231D1E592D11F3BF978EAD286FF2FABF132561754447CD3FAE5DBB7D6A7407C063BE0671677D20C069EDFD03D0040EC07F6C3BAC302E1040C0CBA057EFEE0CC0B6B11631770BF93F701645F5B96A0FC01F96741C8DADD23F439DAACDA15EF6BFC35E242BACEB10C09A3207523CACF33FBFB2E28D18430F40246DA3BFE9BAFA3F381B77A5B96B0BC0962F53ECC2071140868AAAB0CFB2FD3FC4A0E752ABBD0440D0A2772CC39110C08C00B577F587E83F6251FAE246B6F9BF339827F5543D154088A395306C690FC0734B98B7AF7010404E7009C4A933F8BFEC412F1C86A01EC014F00A60B786F43FDAE3F51366C613C0222E979365A2CEBFB2A0383951A3E03F35C8F74E43E401C0D0F9E0009AC311C0DCF47DAD878ADD3FFF9A2BD7AC7FC8BF8A0D9D0FBDF5FFBFB218F12CAB0121C036511A7CC959FABFE7B241CC108618C07C8480B256A9FD3FDC64C213CEAA0BC0D8AFC97447DAF33F14B19E25A3FC14C002A5A64695E302C0989706206CF0FDBFCC9593C510F303C0F58391618DF803C0342AB62CB4761240908AC83FB3991540A9CEFE61C86510C0F05C3565395CBD3F95525BEFF7B4074096EE523D270DF93FFEC57B9F2FCC08C0780F14DC4F9C15C06A95DB6E3FC41640E64CD0EE979BF13F9E72027E987F00C02AFF5F1D214E1FC0643F1F7797800D408AD92DA0A1EC1940FAEE6AAB94170BC018435826B0D41C40E21DD5464D74B1BF8CB98D228F74D7BF2CCC5CF40EA009C0BE30850A6B3906C0B665F3BB5C070BC0937F48F072B310406B3717D701EF0A40152AC54907A408C04F05043B270D0640E48D51D4E0B2F93FDB23F58FBB62F13FC133ABE9377A00405F8EE015B39AB1BF7C216CF488FB01C0D476D9909AA806408026EE39C8F117C0C21BF1E0AEA7004077F75F08350FF83FEC82F37F1959F6BF48CE02E14C870040536A430B81BAF8BF82F57E356ABF05407E24C209D539EF3F5D973624FDC6C93F5E72371EEDC8E83F4CE0EC5237F00940FC287981A40FF8BFFC74AA5E52160AC018F9BC172B22F33F05372716C97F00C0B6BC1FD420681440C926709A397A02C0A88BEC7C2076E63FD8337A4D675E03C0EE67DE94C0210F40DC6E3AAA9C0011403E1EDA6D59F409C03468D09C8149B1BFC57C093A91670640F16CFAC0A5A6C73F9218671A63660AC014A9F738E74B07C0DE743BA121B41140F1F6FD51B718E2BFAA13750342E0EB3F86F12059843712C0328A7CCAA891FABF8A38514FED42E03F156D1BAFEB82024092A7E0D05E98E63FB3A1BA703FCD084048ECEB94459D0D404AB81A5304DBA03F93702347446406406726F0F72577F3BF4E9B4CF2149A19C0BFE53E5FC5F70AC0EF85A2E8472AFEBF0E3848C38022F1BF7E2C534FDB08F6BF2852B5A238A9F33FCB02649D8EF7D63FC155AF8F8EA8FEBF524646F27DEEF53F5640BB941A8F0340E6A9C6852CB711C09854D0D0ECA606C0C30097DC083E0540C7F7B65B8635F8BF637B4E8938F4D9BF2B72F38C40A4FBBF54A3F49A0EB000C0EAAB4ADAE8BC853F33815DED4EF912C04A85FF4478B41140FFA978A331D316C0E18092881B3F05C04E242074D1C0124072227BD10529DABFB46748FE0BDDEB3F669966E3A5020340244B7625042EF53FCB4BC123C181DEBF1B3B4246836E064064A98F0594EAF23FA068D91F4BEE0F401647BFF26D6DF23FDEE94A532075E53F5D109D89695EFFBF6E1A4527BC6E1AC0E8C6567B3526F93F5A7B409AD2DC0440"> : tensor<5x6x7xf64>
    return %cst : tensor<5x6x7xf64>
  }
}
