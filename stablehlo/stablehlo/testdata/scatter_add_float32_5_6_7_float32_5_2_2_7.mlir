// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<5x6x7xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<[[[0], [1]], [[2], [3]]]> : tensor<2x2x1xi64>
    %0:2 = call @inputs() : () -> (tensor<5x6x7xf32>, tensor<5x2x2x7xf32>)
    %1 = call @expected() : () -> tensor<5x6x7xf32>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 3], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1], index_vector_dim = 2>, unique_indices = true}> ({
    ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):
      %3 = stablehlo.add %arg0, %arg1 : tensor<f32>
      stablehlo.return %3 : tensor<f32>
    }) : (tensor<5x6x7xf32>, tensor<2x2x1xi64>, tensor<5x2x2x7xf32>) -> tensor<5x6x7xf32>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<5x6x7xf32>, tensor<5x6x7xf32>) -> ()
    return %2 : tensor<5x6x7xf32>
  }
  func.func private @inputs() -> (tensor<5x6x7xf32> {mhlo.layout_mode = "default"}, tensor<5x2x2x7xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x463513C0074F144039FB0AC0F15FBF4064C34C40DC769B3F86DA0EC0450598C05D3785BFA8CF73C046324B40F733B43F188849BED3A9FB3F5E185A40CDDA53C0E92485BE0F17DCBF86877FBF9EE111BF64C3A53D55D692BF8F5A7FC02573F23F1EC6CEBF4485F13F774C6DC0EDEC88C0CF89CE3F6827A3402D23394087CA83C05FFFACC08F31EC40F49F2D3F0E9C40C04BB18EC0E8C8BC402F5FE0BEF4A74440F2DF48C0873B03402099E1C0F2DD2DC021DE30BE797D5B3F47002140FE9027409466A6BF854B40C0A938BB40BDEFDF3F391A81C023A47C4065FFE73D07A544BF4069274094708CBF1ECE37BFA15A88BFF9D59040037048BFA33291BFC71333C045837340A3FB80C08BCA2D401350B9400AC64C40E3A483BF2C29B6C04052164028C005C0F80187BF7B3CA6BF4CE028C05C94E8404AD81DC0C44430BED84DC9BEC578FF4011A337405C089340C17C234049AE833F0EB1E94024EE7C3FE8A138C04149453FD8639C402A519B40F086AEC02B6F67BC7694F8BF8A86493F8B264EC0F79563C0CCDA4BC002D4DC3E465DF3BF3C619ABFB49F9EBF1871903E582A0B3EEF2624C09573CF3F56FA0B4039C5A8C0613E4BC0A846ED3F7124B6BF71FEDD3F2AEBF1BF0B8E5F40FBD3853E413352BE569434C0A0FC48C06D4320403101AD3F1F565AC04F725EC072F8CA3CB7D3EBBEF151E7BFFD75C6BF1058C83F14E9FEBF31623C3FE91033400B0949C0162583BEB7274B407D33DEC03E507E40DB00DD40F2A48640B44AA7C08E8AAEBF77EC69BFB737FC3F6067823F036796BF56A0103F1DA92EC0FDB86EBE74F5F1BF19761341A39800BF97367EC003FC60C0704919403D0704C07E22D6C0B2568EBF0C6873C0CA3D1B40A11527C09B1D2CC01E8BA7BC7CAFD93F95ADC5BFC839A040D27F283F4CD8AAC0DA61473FA7BD943E7D5B93C000B0BF3F0EFC71BE2622743FA76D2140E8BD0840ADE44EBFF71E9040AF9BD83FBF0226C06CB22A3FBAD09F400CEF443F4D337EBFCFD92940087DD8C03088173FA18E41C04B0128C096A803C0E0A4F63E23F28BBFA15E893D498ED63F0A9C3BC0CF9075BDF464013F85184A40430A453F1B43F93E1045EFBF6EFDB240CF0B1B407BAF4AC030CD6940224E943FE289064158711BC0A5E1F63F357F54BF9BA704BECA99B2C0BFEEE5BF"> : tensor<5x6x7xf32>
    %cst_0 = stablehlo.constant dense<"0xAB9A6040F0D9CA40B6E87940E10948404FDCF53FDE9B453E11772FBEF26E493F91BF92BFABC03C3F4732CE3F605F584094929B40641451BE3BE26BBFFB763A40C55326C03E7B6940C2FE21C0C193D240C8E88340C9084B40898A0241EB68BD3FDAC352C07CBE9DC00A8DC7BFEFFE06C06CAE3BC003D82FC05FED07BF49F532C0651BED3EEF141D3D7FD5FF3F5B7740C02FD8F9BEFDDE5AC06117A8BF85539B40B5D44A40D13CC94001EE2F4029D8494079F09B3FE1E750403C3045BF7CC4CABF19A723BF5DD5CABF46E254C0A2FF1B405768C74012A63BBF7624BBBF2B99224043F48ABEE666D23FAC975BC09347EFBF750954BFF65B723F7CDEF1BEE03208C0C02EC1BF4B94BA3E5A0245C07D295CBF91E6E03FFFA9D73DD1F9A6BFBE7622401488853FCB4D8B4067A787BF0A2890C0D62EF33FA0A1C9BF4EE6BEBFEDA045C08ED91940CDD46FC07B8F8FC08D021F40A3BCA04057559FBECB73F3409216D3BFB540BCBFDBF317BFD59AACC036E0F03F4AFCAAC0C014414029C7B9BFCBF1C23FB7CBAD40F310EC3F92B3263F1EEED2BFB5CC973E4DE8E5BFB47281C0A4479E3F4158A1BF3B0707BF3B0606400E0258405E6203BE4E3BD23FA34945C0DB6F90400F0242C03257F13C01544F4036779FBFB7E128C03A0B333F4E2AA740EFF7BC3FD0515BC0410EBF3FA5A0AE3FCBBBC2BF8A1CA4C05805EAC087F47EBF9D7826C09B9469BFF0BF7AC0209BE1BFBC3823C0DBCAEB3F8BA2AB3F22DF0DBE607955C01CB281403082D2BEDAF847C054F54EBF"> : tensor<5x2x2x7xf32>
    return %cst, %cst_0 : tensor<5x6x7xf32>, tensor<5x2x2x7xf32>
  }
  func.func private @expected() -> (tensor<5x6x7xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xCACA9A3FBA800A41FADADD3F71B21141C6D8A340582AB43FF7D119C0CEAE7DC077FB0BC07D9F44C0B5259940AE3C9940534695404687E13FCF1F1F40901ECBBE62F836C06DDFF63FA4E061C08D57C040D67F86409E9D0140CA67854008EE574074139DC056BA42C07E89A8C0646CCCC0CF89CE3F6827A3402D23394087CA83C05FFFACC08F31EC40F49F2D3F0E9C40C04BB18EC0E8C8BC402F5FE0BEF4A74440F2DF48C0873B03402BB81FC1FADAAEC0E72434BFD62BF8BFB4A33E4052052A40D6DD323F7061C0C0269BAB403DCED5BF1120ABC0CBD20C41B014524030A8B040A0ABAB40DF9F0340D412003F90BA0C40E35F70403F7E17C03006E3BF3B3F8CC0F807F53E48EFCBBFCE260F4151DBA1409E67DE3F738DC13F2C29B6C04052164028C005C0F80187BF7B3CA6BF4CE028C05C94E8404AD81DC0C44430BED84DC9BEC578FF4011A337405C089340C17C234070E2413F64250F41235C1CC0D92298C040036CBD57AFBA4042338C4060A0F2C09EFDC2BF63EFC9BFB8A012C0759882C05D45E6BF7C1D45C0A1895FBF6C20233F40C926BEBC4B4740421647BFB7CE8BC0103E2ABFA03E3A3DBC1C323FD8CA05C14C9345BFF262F2BF9718BDC0E30087402AEBF1BF0B8E5F40FBD3853E413352BE569434C0A0FC48C06D4320403101AD3F1F565AC04F725EC072F8CA3CB7D3EBBEF151E7BFFD75C6BFA7D2D240355F13C009800541400B933FB39493C0668659BFF30D0EC070FBA1C0AC50AFBF9EC51E4150663040821C6DC0142982406F356E3FC0C827407C0D21BFACE760BF22989DBF42C7D8C08470803FDAA649C0A5050B4124C0CB3F24D218BF293269C08C33814070A8A4C046650BC0B2568EBF0C6873C0CA3D1B40A11527C09B1D2CC01E8BA7BC7CAFD93F95ADC5BFC839A040D27F283F4CD8AAC0DA61473FA7BD943E7D5B93C01E54C4BF28D153BE452E86401864A33F3C8F00BF98CBDEBDA2A41B41CFC94A4048AAC0C0BC330A40E378CB408A8840BFF4E2C3C0701895C0995BF8C0919600C0C8F37BC09E60D1C0267674C0206404C070B13F3F7538B43F65D2C43FB58AC8C0F58D7F40E01EC13DC0EA073D10B11EBD1B43F93E1045EFBF6EFDB240CF0B1B407BAF4AC030CD6940224E943FE289064158711BC0A5E1F63F357F54BF9BA704BECA99B2C0BFEEE5BF"> : tensor<5x6x7xf32>
    return %cst : tensor<5x6x7xf32>
  }
}
