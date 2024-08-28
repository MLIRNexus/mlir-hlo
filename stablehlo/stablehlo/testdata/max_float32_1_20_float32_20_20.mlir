// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<1x20xf32>, tensor<20x20xf32>)
    %1 = call @expected() : () -> tensor<20x20xf32>
    %2 = stablehlo.broadcast_in_dim %0#0, dims = [0, 1] : (tensor<1x20xf32>) -> tensor<20x20xf32>
    %3 = stablehlo.maximum %2, %0#1 : tensor<20x20xf32>
    stablehlo.custom_call @check.expect_close(%3, %1) {has_side_effect = true} : (tensor<20x20xf32>, tensor<20x20xf32>) -> ()
    return %3 : tensor<20x20xf32>
  }
  func.func private @inputs() -> (tensor<1x20xf32> {mhlo.layout_mode = "default"}, tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[-2.50558591, 3.33518052, -3.30435514, -1.74195266, 1.48053682, 0.564161956, 0.0351434201, -0.52820009, -3.64032626, -4.3281827, 0.163584158, 0.117979258, 1.98972178, 5.67226696, -1.37462115, 5.30714369, 1.36005414, 0.978463768, -2.3208797, -2.92100811]]> : tensor<1x20xf32>
    %cst_0 = stablehlo.constant dense<"0xDEB68F3E9B8CC7406CFFE1BE80C4AE3F65738CBFE7A7A340DC7BE9BFB405F2BF9BEF184037D29440F29811BFC98928C034BFD7BFF95394402D7D503F0BFCF7BFCB148F3FA4E082BFD07AF03F761232403A496840CF26A63FB358EC3FD066ACBFC8A202BCC720A9C0E8E731BE13E28A40C2524BC08F864A4076B969C0775EE53F0CE228C022E292BFF1E06D40945E81BE94B993BF5C7B1CC08AB5C53F7190CA40C1052F4089E1C4BF03ED9BC0613FAB3FD777C7C05EB960407693983FA3EB1640D131BEBFF1608A407E99E43F7B127840B3DCF7402C3B62BEE145FF3E893A5E3F2D38C93F8FB50DC018D3D8408919843FFDA703C00811EFBFEC16CAC0C0E2E9C0DAB2A0BF65BB413E5BBDB5403E67EFBF572B73C09755873FCB878BBFBB9CBEBF5D112940995FDC3F6684133E82B4033E858C31C043EAD93FC75C993E225DB5BF53C658C000E6343FAFB9C03F73817DBF6BBF28BF3CB53D40A946B540DAD3F1BE0158783F24F039407BD565C0EC3C7AC074A7363E8519CDBE220308C0B8E12F3F1B9012C017491940BC82A23F5A82C1BE64B453C025D3EBBF072A31402E8EDC3FFB0B40C0BDE994C04486294063894E400281EF40D2D88140FEC72FC0BDF31540B21563406FBD6DC0A6921F3E02BE80C0327232C0DF3B44405FABB4402CA25340EFA7623FABBB4EC0524871BF7C28A54065365FC0B6EFE740C44DEBBF58D112C07D1CB1BF7F58573F8684AA3E55F28540FEB6D7C0094B07416377243D86C0F3BEC7B956BF2368AB40E709A0C064A80A3F5C4D0C3F5FF76E3FA25585BFD44399BFD27CC7BF433EF2BFF8F257BFF623ACBFE6645A40F181F9BD2CDE15C0B8836540A5F00640EF3CD6BFC32A4FC03C8937400F633BBEEE2AA03D1F2197402C890B3F01B9A0BF275E6A40971500BF2E5F6F40B950B6BF4E75033FE8AEE3405DCBD4BF1E433B3EDDC472C0B68F7E40556D38BE33D073C0735EB9BF112BB3C0FCA3FD3F2C0B39C09D81173F8DABE840FDD135C086BE1FC0751FF8BFCFA5C4BDE2B89E3E93990CBF2722EABFD8CDB7BF195FA53F277D59404F2C71BF0F1C95BE747B3C40264AFB3F5F1FC0BFC33058C057D5B0C00508CCC086939FC0138993BF2A3D84C0E5A52D40457472407A83E5BF19FC9EBD5C8C1A3EF2788EBE62B021C03DEA303F239D7940D8588A40C7C509408B31C33FAD479D40BF461D3F30F1A1403219FDBFCCFD76C0B5A9F7BFCBD69D4057EF94C0368268BF2EB96FC03CCC77405E776DC08E63F1C04F49EBBF5BBEFE3E03DD363F6862B0BFC0C1F6C02D8390BE3599D1C017ABE43E6E371BC021CCBCBF171CC03F8736AABFAB7E883F04C2A83F1055F23D525318C0C83F454013AF533F4EBC793F60FD93C052174B40E859CA3F7B45674076F251C0D3CD923F8FC2F23D5049ABBFF2423D40874FD63F7CB3D4BE820B1940E50BB240BDBB00402CB9573FE932BFBF8E2DB33E22F6633FEAB6D03F078B3C3E577C58C03456E840BA08893F1D318EC0F587F33FA9EF8940E15689BF92EC82BD3C46813F7B2B214134EEB73F3CD216BE9A8A473EF7F01AC0D67938402ADD07C0EA9479BE01A3CA3FE0B07140B6D1A1BFD0FD2B3F8EA1D7BDF30CB6BD4E4F8D404E2AB6BFD17DFFBE541BE6BF7BCE0E4084E1083E0AA530C0FC0020C0CA7C343F85242E3FC078DB408F0C04C1AF8E8BBFD2129F3FADB5BD3F4ABBB6C018031CBF143547BE3E4C8D3FCFB52940668573C0719E0F40436ED4BF1D3436406AF760BE51BE97409E46283FF5217D40EB84023E5BECF63E425FE23C31AA7ABF0EF06C40D53DA8C0373939C010EAC0BF49AA5A3F55F46F4011FB0EC0F407A6BDAC539540C0FDB2C03CAB8CBF7B990FBFA50E6ABF9760CDBF6DBECAC0B9F5B43F3742E23E2B2F81BE394ABDC039A2D2BC5313CD3E320BD3BFF34F57BF496E66403DCD75C0CFB9073EE6725840A38BC0BFF85AADBFAA2D1FBF7D88BEBEFD4E15C07B4351C048F35BC06FEA06BF486C933E570D9840B6E5B940FD36D73F30CC093F676FA5BFAC098AC051EB8840F45EDDBFC35D54C0AEFB3EC08C4D613E1CBC48BFBDDBDCBF695A66BFA3DB04C0476E0B40C28E04BF2086EFBEB25C71C0D6696940B06A094037DBF2BF0BFF773F1A5DFEBFD2A2BABFC7464BC0A3814F402BACC53E698D033E8BAA38409E79A8C0ADB5354099C04040DDC0F13FE40CC23F534ED9C00CC14C4047A9C0BEF1C16440B5A6B0BF46435F3FA6845D3F58B066C0D993D7C02C8FF3C0"> : tensor<20x20xf32>
    return %cst, %cst_0 : tensor<1x20xf32>, tensor<20x20xf32>
  }
  func.func private @expected() -> (tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xDEB68F3E9B8CC7406CFFE1BE80C4AE3F3B82BD3FE7A7A3408CF20F3D1F3807BF9BEF184037D294409B82273E1C9FF13D34AFFE3F3683B5402D7D503F1FD4A9404116AE3F9A7C7A3FD07AF03F761232403A49684099735540B358EC3FD066ACBF3B82BD3FEB6C103F8CF20F3D13E28A40C2524BC08F864A409B82273E775EE53F34AFFE3F3683B540F1E06D401FD4A9404116AE3F9A7C7A3F8AB5C53F7190CA40C1052F40997355408E7A53C0613FAB3F3B82BD3F5EB960407693983FA3EB1640D131BEBFF1608A407E99E43F7B127840B3DCF7403683B540E145FF3E1FD4A9402D38C93F9A7C7A3F18D3D8408919843FFDA703C0997355408E7A53C04EF8DEBF3B82BD3FEB6C103F5BBDB5401F3807BF1BFB68C09755873F9B82273E1C9FF13D5D1129403683B5406684133E1FD4A9404116AE3F43EAD93FC75C993E225DB5BF855B20C099735540AFB9C03F73817DBF3B82BD3F3CB53D40A946B540DAD3F1BE0158783F24F039409B82273E1C9FF13D34AFFE3F3683B54096F3AFBF1FD4A9404116AE3F17491940BC82A23F5A82C1BE855B20C099735540072A31402E8EDC3F3B82BD3FEB6C103F4486294063894E400281EF40D2D881409B82273EBDF31540B21563403683B540A6921F3E1FD4A9404116AE3FDF3B44405FABB4402CA25340EFA7623F99735540524871BF7C28A5403B82BD3FB6EFE7408CF20F3D1F3807BF7D1CB1BF7F58573F8684AA3E55F2854034AFFE3F094B07416377243D1FD4A9404116AE3F2368AB404B8914C064A80A3F5C4D0C3F99735540A25585BFD44399BF3B82BD3FEB6C103F8CF20F3D1F3807BFE6645A40F181F9BD9B82273EB8836540A5F006403683B54096F3AFBF1FD4A9404116AE3F9A7C7A3F1F2197402C890B3F01B9A0BF275E6A40971500BF2E5F6F403B82BD3FEB6C103FE8AEE3401F3807BF1E433B3EDDC472C0B68F7E401C9FF13D34AFFE3F3683B54096F3AFBF1FD4A9404116AE3F9A7C7A3F8DABE840FDD135C086BE1FC099735540CFA5C4BDE2B89E3E3B82BD3FEB6C103F8CF20F3D195FA53F277D59404F2C71BF9B82273E747B3C4034AFFE3F3683B54096F3AFBF1FD4A9404116AE3F9A7C7A3F138993BFCCF13AC0E5A52D40457472407A83E5BF19FC9EBD3B82BD3FEB6C103F8CF20F3D3DEA303F239D7940D8588A40C7C509408B31C33FAD479D403683B54030F1A1401FD4A9404116AE3F9A7C7A3FCBD69D40CCF13AC0368268BF997355403CCC77404EF8DEBF3B82BD3FEB6C103F5BBEFE3E03DD363F6862B0BF79808AC09B82273E1C9FF13D34AFFE3F3683B54096F3AFBF1FD4A9404116AE3FAB7E883F04C2A83F1055F23D525318C09973554013AF533F4EBC793F3B82BD3F52174B40E859CA3F7B45674076F251C0D3CD923F9B82273E1C9FF13DF2423D403683B5407CB3D4BE1FD4A940E50BB240BDBB00402CB9573FE932BFBF8E2DB33E99735540EAB6D03F078B3C3E3B82BD3F3456E840BA08893F1F3807BFF587F33FA9EF89409B82273E1C9FF13D34AFFE3F7B2B214134EEB73F1FD4A9404116AE3F9A7C7A3FD67938402ADD07C0EA9479BE99735540E0B07140B6D1A1BF3B82BD3FEB6C103F8CF20F3D4E4F8D404E2AB6BFD17DFFBE9B82273E7BCE0E4034AFFE3F3683B54096F3AFBF1FD4A9404116AE3FC078DB404B8914C0AF8E8BBFD2129F3F997355408E7A53C018031CBF3B82BD3F3E4C8D3FCFB529401F3807BF719E0F40436ED4BF1D3436401C9FF13D51BE97403683B540F5217D401FD4A9404116AE3F9A7C7A3F31AA7ABF0EF06C40855B20C09973554010EAC0BF49AA5A3F55F46F40EB6C103F8CF20F3DAC5395401BFB68C03CAB8CBF9B82273E1C9FF13D34AFFE3F3683B540B9F5B43F1FD4A9404116AE3F9A7C7A3F39A2D2BC5313CD3E320BD3BF99735540496E66404EF8DEBF3B82BD3FE67258408CF20F3D1F3807BFAA2D1FBF7D88BEBE9B82273E1C9FF13D34AFFE3F3683B540486C933E1FD4A940B6E5B940FD36D73F30CC093F676FA5BF855B20C051EB8840F45EDDBF4EF8DEBF3B82BD3FEB6C103F8CF20F3D1F3807BF695A66BFA3DB04C0476E0B401C9FF13D34AFFE3F3683B540D66969401FD4A9404116AE3F9A7C7A3F1A5DFEBFD2A2BABF855B20C0997355402BACC53E698D033E8BAA3840EB6C103FADB5354099C04040DDC0F13FE40CC23F9B82273E0CC14C4034AFFE3F3683B54096F3AFBF1FD4A9404116AE3F9A7C7A3F4B8914C0CCF13AC0"> : tensor<20x20xf32>
    return %cst : tensor<20x20xf32>
  }
}
