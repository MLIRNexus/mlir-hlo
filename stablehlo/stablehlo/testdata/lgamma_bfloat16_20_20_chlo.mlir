// RUN: stablehlo-opt --chlo-pre-serialization-pipeline -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s | stablehlo-translate --serialize --target=current | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xbf16> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<20x20xbf16>
    %1 = call @expected() : () -> tensor<20x20xbf16>
    %2 = chlo.lgamma %0 : tensor<20x20xbf16> -> tensor<20x20xbf16>
    stablehlo.custom_call @check.expect_almost_eq(%2, %1) {has_side_effect = true} : (tensor<20x20xbf16>, tensor<20x20xbf16>) -> ()
    return %2 : tensor<20x20xbf16>
  }
  func.func private @inputs() -> (tensor<20x20xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x93C04240C53D81C025C0F03FBABF0D4068C08540283FF1BF01BE33BF42400CC0823ED7BF503ED03EE33F863FC33E663F9B3C61402540224037C0C53D7B4091C032C0C94050C08DBE42C09D3F87BF1640264091C0F1BFD3BFE53F4FC0393F9C3FD5C0114087BF9CBE973E9BC093BE29407B40934024400EC017C03340834084C0843F1B409EBFA9BFE23FD63E0A419640904018403640773F2DBF5BBF57C066C0A6C026C02F409B3F15C0373E06C0B5C0713F0DBEC3409FBF11400B3FDCC001C08040C63EB0BF823FFFBFC13F94BF5A40B7C008C0BC3EB540A5C0B5BFE1BF7BBFFBC01640DF3ED63F843FCF3EA4BFD93F744081BDBDBF04C0203F48C0D03F983F82BFFEBFDEBF374077BF54C04CBF04C03D40BB3F7A3E79BF8B402340BBBF0A3F04C0B13F8D3FEA3F04C0A0C084C0CE3F2840003DA9C0073F3C407EC055C0BA3FC640E53FA2408F4007BFC53EB2C055C00E40EF3F1DC04CBF1EC02D3FF93E42402ABF14C0DFBD16C02E4099C00440A54011C025C0FCBE95C03DC07BC0EEBF13C0284056C04BC0A4BFD5BF263FC6400FC06540243FC2BE70C0F0BF4E408F3E90C04AC09140E2BF963EA63F853F893F0FBF3D400040A640E33E42C029C007C0123FB64008BEBC3FAE3F3B3EECBF04C09F403FC0F53F4FC010402B401DC08DC0DF3F0E3F9EC040C0B740C3BF3EC0E1409ABC61C07EC0A13F3D40A94011C0D73F2D3F35C0A2C0E23FAE3F0AC04EBF5C405140B83FCDBFB03F78BE27400FBEB640353E2B40264007BFB0C08A3F843F8FBFA8C0693F3EC034C0A4BF0E40BEC0DEBFC33E0BC025C01EC030401A4090C0254085C097C00BC019C08F40F03F95C007C0FCBCAF3F90C0673E163F06402AC096BF2F40AABE21C09040834032C00ABF16C0A9BF50409A40CBBFCCC0A7BF01401D408440C140BFBFCBC0333FD23F8340B5409FBFB4BFAC3F43BF584041C09F3F1F3E3140253FA740EDBF033F0BC093C05040B94034C00FC00340203E14409DBF89BF923FDE3F2F4002C0523F04410DBD56C0EE3FD9BEC4BFD13E7340654016C0573EBEBF82C01E408BC0563F06C0AFC0A640683FC93F4CBF2340FE3F3E4036C0344047BF9BBF0DC0644099C08240A84062C03CBE"> : tensor<20x20xbf16>
    return %cst : tensor<20x20xbf16>
  }
  func.func private @expected() -> (tensor<20x20xbf16> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x3BC0393F1340783EE7BD43BD673FCA3DB4BFFF3FA23ECA3F0A40BA3F393F5C3FA33F653FC13F483FA1BDCFBC593F8A3D7D409C3FAF3E9D3EC13E1340D93F37C09B3DA94020BFC33FD13FBEBD3940393EB53E37C0CA3F5D3F98BD0DBF703EB9BDD2C0093E3940BA3F8F3F28C0BF3FC73ED93F2540A93E323F493E043FF53FA2BF8DBC6D3EB73F933FA5BD403F1D412E401D404E3E0E3FAF3CB43F014082BFB3BF58C0F0BDED3EB5BD903ED23FCD3F96C0163D05409E40B33F093EFC3EC5C05D40E53F553F833F10BC8540F7BDE93F8D3F95C0A63F633F87404AC0753F843F7C4006C1393E363FD0BD8DBC493FA13FC6BDC83F3340613F0240B93E1E3EE0BDA7BD85405F407B3F113F57405EBFDE3F0240263FF9BDA83F67400F40A33E653F003F0240F2BD4FBD81BD0240807FA2BFE4BDC13E5D4078C0053F233FAC3E6CBFF9BDA44098BD51401A40A23F563F94C06CBFDC3D4EBDC43BDE3F8CBC953E1A3F393FB13FA93E1340733EE63E34C0E33C5B40FC3EE7BDA23F3CC0AA3F00BFB73FC33EC13E78BF4FBEA13F613FA83EA4401F3FA53FAD3EAB3FA9BFC33F673F963F34C0C2BD2040873F8F3FDCBDAFBC16BDA43F263F00005E40313FD13FE9BDB83FE43E88400740F9BDEEBDCF3FAC3F0240484019400BBD0DBF003ED33EC43B28C0B1BDF23EF3BF807F8A40593FDB3FD4407F40AABFAC3ECDBD263F6740FC3ECDBD953E6B3E07C0A5BDEEBD873FE23F913F743FF8BD573FF1BDCE3FBB3E04408840D43FD33EB53EA23F91C025BD8DBC07406FC0713DDB3F2F3EA13FDC3D6CC07B3F593F743FE7BD8CBCF33E623E34C0AF3EC2BF3AC0743FFB3D1A4043BD3CC0B83F6040F0BD34C0B33FD73E2E3DDBBDDD3FED3EB43F94BD1D40F53F9B3DA33F733E933F703F3A40563FC2C0983FDB3B813EFA3F9B405E3FBFC0863EDBBDF53F8740B33F783FEBBDCE3F883F1640C6BDE53FFA3EAB3E6140B13F0D3F743F3BC0703F8D402F3E1F3FA83CE43F263EBB3F284087BDB5BDED3E3040083E1141594078BF59BDA63F583F473FC53FA53F733EBC3F5F3FFDBE873E1CC0F33DCD3F8FC05E407D3DEDBDDE3FA33ED6BB2A3F983E073FD53FC43F463FA33F34C0EF3F6440ADBFEA3F"> : tensor<20x20xbf16>
    return %cst : tensor<20x20xbf16>
  }
}
