// RUN: stablehlo-opt --chlo-pre-serialization-pipeline -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s | stablehlo-translate --serialize --target=current | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<20x20xf32>
    %1 = call @expected() : () -> tensor<20x20xf32>
    %2 = chlo.lgamma %0 : tensor<20x20xf32> -> tensor<20x20xf32>
    stablehlo.custom_call @check.expect_almost_eq(%2, %1) {has_side_effect = true} : (tensor<20x20xf32>, tensor<20x20xf32>) -> ()
    return %2 : tensor<20x20xf32>
  }
  func.func private @inputs() -> (tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x09D0A4C002A8B1BF2EE1B93F72ED383FFD7F0EC00013B3BF96858CBFC564B4BF01EFB3BF85F56CBF959801C0141DA64078D8993FA4F565BE09474CC0C19EBC40B96836C05E1AB03D71469DBFD8138BBF41BC98C07F69DFBF2AC2B4BF1686B5BE9CA7C0BFB46F84C0AFA583409AE28F40A77D30406B2A79C068115B40FB156A4016F4B64006AB3D3F679A0FC037A385BF883B313ED51783BFE8F22240EB5510401A1E9F3F7825D6BF20EFFDBD6AAD0CC0398C6E3F854B61BF2D7E82C0FE9CC03FC24ECCBE14799040A0FF4B3FEB44FF3F3E1683C0B30FC1BFEF22A04083E1AB3DF194673F119966C0614883BFAB4C26C093C78340CC8A8EBEAA44CD3DC0FAA9BF63EDB03E91A89ABE64B2C33EEFCBB6BEEECC9640CA79F53EDC6F7AC012448240956444BFC4869ABF6CE598C06FC022407238893F624A03C068F13D3F504A0D403C408A409247FE3F7BE71440789D15C042214840342E82BEC09EE53E33736BBF46077DC0E8B4FB3E91C92EC0CD565B3F69B52C400441164068657EBFF975FE3E4ADE75BF9328FABF05D105C0CFC18CC05E314DBF02EF80C0808F7CBE633D1CC0FFE3E43E6B25BB406164353F87D89CC070CE1E40E0F0AE3F5A18BFBFE6E7E4BF63A033407A924FC0646694C03B80B4BFA80087401441CF3F30AA404036E00DC0BABEE33F26B3AEBF6DFDB73EF4EE86C0F27B0B40EE972E402CC6713EA468EDBD207227C06F5CF3BF2E1A1B404F759BBF8A3A8CC03FD04D3D0B6666BF0675ADBFB97B4FBE595F043F1C151CC0DB0A2740E860A43F8E81CCBFB12E434026381540E9BA34BFB41F083E667BFC40AADEF73F4EDBBDBE4B15B43F703814406F72164011F7D4BF8E982CC0BA733E40695FFFBF054A684075011240CFF1D4BF201C2CBE751D153E30D4A6BF27A2AF409C2BB440A94482BF5144CABEE754B23F0021493F722A0AC041858CC0AFB0E43F53ADAD3E79F29EC0AA0FC9C0983C1140A7B987402C63873FA17BCE3FD6F3333F04F39840755AE13F2E279A40647D25C0715324C0ECE5253FE1445AC056AB6D402691B2BEFCA42BC0634C3BC0C6F40440BEC012C0F02ED43F6F89843F2B7B13406BD0EC3F907B5040A0C1523DB06F06C08E51A4C0AAB601408B712B40749F2340BEC1A5BF27ACCD3F9CF5E8BF4BFF6840136276C005F801C0427A993F136FCDBE7CB5543FFA3AE63FA2D5453F2B24E1BF3FB20C3EB0855C40B1B70BBE1C2F0540D44AF5BF5940B840F041633FDB278DBF673CA63FF19A2DBFF9C343C009122D40B82952C0818602BF15E85BC0F43C1440FEF17F40DE5C7C3F18418C40167AA14052C164C06F018BC0A7E9863ED392F9BF7D4621C00E68554044C43A3F5F0C803EAEDE523F0116CABF311650C0B421F6BFBA2E98BF1DBD53BF45295440EC6625408D6B0740C503A74069B6B73FBAE31440AE5481C024C0EBBFE8E95F3F1A09C3BF36807540C2348E40D1685B409530A7BE093F90400B6BA940742F0A402C225EC05C9933BFA6C92EBFA3A1E63F2F08D23F026BA940D5955E4044F8C5BEBF2702BF074394BF93D7CBC034A3A14084063FBFC556EB3FDD80163EC28CBE4053A50FC01F1E253F83E4603FDA631A411B852CC068CA0240350874C02280DD3F42A6BA40754726C01785C7BF39D347405DF8C6BF05B8AA40352E2D3F7FBA42C0DFDF00C0FBFF4B40C1E11B3F90565B409C3811C1135A8E3FF22D3E404EC5853F38EF963FD0147B3FB9085BC0ACB1D03EF59D65406A96A7BEA38678C014862CBFE255C43F75A1643F91A6C2C06837C1C012592340DA891B40DAC01E40546902401CF04D40CD5DAF40EB01F13F38C05BBEF8574940160588C0000E6C3FADACE8BF7941FFBED440F53EC5F5F4BFE8B292BFA65B9940B60F0140D5E4A2BFBBAA9CBF72729EC08F58A74080617F4087FB64C0FD8E1440ED9B3EC0CAE9B6C026DC6FBEC4C074BE85B1623D23C0DA3FE4E672403A04AD3F1EF30E409F22993EF9194BBFF2C13C40EB27823EFD4242407C2F4BBF33FA30C0890155BF8F0DBF3CC744DDBF56034CC0BFA363C0343619C084189CC01BE5DB40CB86D04099852DC0F13B23C087F3053F430A11C066074F3E67113040F8375240C38A0D40BF9D41BF9BB7EDBFA62F3840641FD4C0E71DCE3F3017F8C01E4C9A40F7D6E4BEC7F5D0C05681E1BEBB06883FC64EE2BF599B2B40DCABD6BFCF6A1F403E5F02C062B846BF457B89BFA0EA9040CB4720C0E7FB4CC09FBD4B403DEBB7BF9F8334BF"> : tensor<20x20xf32>
    return %cst : tensor<20x20xf32>
  }
  func.func private @expected() -> (tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x0F4E47C072BE7F3FC0B6F8BD60E46F3EBA98283FB4CD7A3F17F112404080763F2AF8773F1CCA284091783E40E6105E4000FAAFBDF8C3D53F70A2A6BE467793401435A83E76391A40759BB93F7DE91A40D67F35C038B8803F3C5C753FEE32AF3F6E485B3F70CCB0BF76E7F73F67B81C404088F63ED04243BF3CF88E3F5C7EB03F53008A40C0655A3E0EE8143F66D1464007A4D63F97A86D40389CA23E80F3023E40FDC5BD240A633FC00B0B40240C4D3F0062313DCA300C4010D73BBF80FBF6BDB660A83FCE5A1E4060D01E3E00701DBB846E78BF0CC35A3F82CE4B4018D61B40C0D7803DC236B3BF07D16940204BF1BD1696F83FFDC5C13F6F051040F54B903F04A7723FAFF1BA3F02E9573F1DBFAE3F5B48304082211D3FB8C017BF1CD2F03F2E6BD03F55B7C53F12D934C09877A13E806919BDC8C90E40E02D593E401FCF3DA0540D400044B8BBA0722E3E1C35823ED841503FFBE5C93FFA342E3F1425244080780FBD0AC9163F80D7EFBC8081CE3DE80BDE3E30D63B3E166AA240D00A143F55E44F40EB181C403C0CD13FA45A26C0A470E03FC8A0A03E62BBCC3F00D8CD3CC6062F3F66FC9040A044803EFF6012C068168B3EC09BEFBD1E815D3F36708F3F6CB6053F7CC517BF002B3CC0B629763FE5B004408050E1BDB4E7333FB07D343F005C9DBD6291853F2C3D683FAC69F3BF80E1AF3D5826EA3EBD9AAC3F4CF10E40509AF2BD041ADD3FE0E66D3E4373C13FEE7B23C039AF3D40D8E91640D630883F5621E03FF81E0A3F40B8EF3CE8DDBA3E40C7D7BD9C3F563F00513D3F208D313E4789BB3F5838FA3FBCDE0441002ED1BC0065AC3F00C9F5BD30C2273EA0C53D3E748C603FD05F99BD14C32B3F06279440E75CAC3FA085123EFC81603F49EFF33F19F4ED3FE0B0983FA41E7C402F6C8540B6D48040DAE1A83FC010F4BDE01F2A3EB0BF843FCC1725C0003E99BDF498773F2860A8BF95FCB6C0004E0B3E0C9906400010FBBC000BE3BDF0BB833EB18136404068A7BDD3053A40A02BECBD90E8DEBDB00FA83E1BA192BF7ED3B83FC648B03F90B0B6BD026C6B3F80E60D3DFC44C93E40D1D4BD00479FBC0098203E80E964BD1488713F90203C40404AC33FA8213FC0003E3D3C7808D63E3089A63E6BCB9B3FC0C9E4BD57169E3FB4FCAD3FF8BF82BFD5B830400047AEBDAA1BA83F4090FC3D005A92BD007C373E63CF843FF8C6F53F4C1D923F1192054080CB143D5208F03FFF268C4080379B3D90BB0F40C018DDBD7A89B43FA8F8783FD05AE03EAC8143BFBFFEA13F78A599BF00EE273E3735E53F001A093CA3BE1240FCDB4F407854B1BF1C141CC055C19D3FC54C1640F0539CBD26F1823F6071673ED9D0A43F80EE043E2E87553F601221BFCE82F93F2A43D13FCC14EF3FDA57803F4007B13E801E5A3D4ADC6040C01BF8BDC04D2E3E40D46DBD63A6AA3F0065B03D3694583F2577CB3FD1141840C6B48F3F5AECB43F44B91D40A15D684000FF993D0BD8A1BF1D55BA3FF59AB53F408590BD8095DABD855D68401E9D963FD502AA3F9DFCA13F83B1E73F4BABC1C0B85850401E4CC83F00E473BD7BB4EC3F47BB96404E2D143FD037AA3E801FAA3D3F4D404110F49BBD00009C3CA82E95BF4073B6BD2F2790408034F1BD6AC4553FCC124F3F32F3553F7A756C4000A9943EC401A83FA899654088795F3F20F0C43E628D8F3FE84326C180E360BD64C42A3F00C7C7BC80F3A1BD00BA3A3CA00396BF0604473F7047A63F92BFB43F2C6E55BF3997B33FC0BDF3BDC0B7923DF77187C0163758C088EEA43E708E723E08CB8A3E003A863C9C39673FDD427B40804038BDB249DA3F04FE543FD7AB04C000794D3DEBED9C3F5AFEA13F7A5C1D3F7A82EC3F2DFBF13FBCB2374000A8E83B0BC1A43F752ABC3F3275D6BFE8E36140A5CAE33F339FB1BFF00E2B3EC22B04403A1295C082A6D13F96B5CF3FD7563740804EC0BD3837C53F8067ECBDC0A5EC3D71AB8C3F0C4ADC3FC49B253F8A9BA23F58DB393F9873DC3F6083163D423EF23FB0B36F40D681783F04129ABE08A9AFBF7076EC3D53F41CC08EE3CA409225B640600A6DBD404CCCBD382C073FD414FB3E4E9DC13F58C1F33E60A5783F408DD33DF513CC3F560BB53F945E153FFDD5D1C000D7E3BDFB4209C118723A4017D9A33F7432CEC0344DA43F806507BD5ED6873F2010D73EB83C643F807D8E3E32772440CF4DD43FE30825406B971F40A0CC79BDF4EBC6BEC0715E3F485A6C3FB54DBB3F"> : tensor<20x20xf32>
    return %cst : tensor<20x20xf32>
  }
}
