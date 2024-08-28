// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<1x20xf32>, tensor<20x20xf32>)
    %1 = call @expected() : () -> tensor<20x20xf32>
    %2 = stablehlo.broadcast_in_dim %0#0, dims = [0, 1] : (tensor<1x20xf32>) -> tensor<20x20xf32>
    %3 = stablehlo.minimum %2, %0#1 : tensor<20x20xf32>
    stablehlo.custom_call @check.expect_close(%3, %1) {has_side_effect = true} : (tensor<20x20xf32>, tensor<20x20xf32>) -> ()
    return %3 : tensor<20x20xf32>
  }
  func.func private @inputs() -> (tensor<1x20xf32> {mhlo.layout_mode = "default"}, tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[2.33575583, 0.00458287681, 0.935180842, -1.41977119, 0.314319104, -0.639137268, 5.29085827, -5.0909462, -0.248644903, 4.20221758, 1.33613873, 6.24781179, -0.609741926, -0.862355053, 3.2693851, 3.03815269, 0.91484952, 0.2029479, -0.503933251, 0.5231691]]> : tensor<1x20xf32>
    %cst_0 = stablehlo.constant dense<"0xC9E967BF492CA5C00F921BC0AD438E3F6E818440713206BFE5D5A53EB1385EC028C952C093FAAEC08C04EBBE118F8D404817943F39C3EE3F7329A23F443C78C02F097A406307AD3FC2706E40DB0ED83F21F3154085621140879ED740B9D31E40CD2020C0FBE8DB3EC50F31C05A58A9C0CC0A34C0B8DE31405CDF04C07B9DB4C0842890C0126A983FE6CE48402C30DDBF48F7D0BFCB301FC098BE83BF9CBAC03EA19239BEA8E1674013968F4098E0F2BF7533803FE3CB98BFE9B9D7BFDE7E1AC052D96C405692A73F6E4D134035165CBE6BCDFABFC52055BFC5D485401F6B74BF603121C0E9EA41409511A23F9254A5BE1A4147C081CB6B3F1F528AC09A0736C0DE5F71401F2212BF1B0F0EC0DD435AC02DB8E2BD14E260BF9FD5AA3D5E049BBF6360E83FF5A82540B5CCC54015A0AE40EBDA713F008BC23F3BA8EDBFB929A33F7D37A4C09A7E9F40332B0ABEFEDF68C019E72740A441BA4027B9513E3856B43FDCE614405FFDC6C0AE78BD3ED3E5B2BF6B0D94C081D62FBF63348AC0DDA08340C98581400510993F8663333F8549C9C0DAAF8DC0E18E77C0FB2898BEBF4124C0F8868A3FA19492BFD3E4D5BC86F54CC0B15F3D3F558E25C0E6944BC057E334409463A8405115E5405F96D3C074333CBF0193DC3F515B004095AF12C09F7F0CC0B47D82C02C9EF43F077BEE3FB7470EC0817282BF80A1FCBF535368BF28B5C93D1336A0C0E02D0740D7D33AC0C1F4473FF148A73FEC310E3F646B83BF2EAB8E4021F157408B36B63F6EC725BFAF0389BE887578C06DDA40C0BABCB4BE303457C04B96CD3E2DC3A8BDFC59C03F4B418C3EF098B6C0A5C9954039746B3F9B5A54C0D92D3CBE1714B3C02D0186BED0EA0AC054AAC5BF05C8913EE167EA3E4BBF733D03C43B403BAC70C0BF1B82BF56C6F53F62D783BF64965B3FB92CECBF455747C05E8DF33D6DE676402A835540A0E1D3405A35C9BF908E833E2767D540EA7DBEBFDD55A4BF68F62BBD0F6C1CC021E2833F8D9C63C0CA23B5C0ACD18440CF5514C00D321540662AB440A35AC3BFEEA092C0F16FD8BF4DA08BC06A10D73FFB7CC4BFB47F03C0D380E13E317F23C0F73CE3BFC3D08640B698A040B03939C0364D08C0D606A1C0D6D259C0F871ECBE21AD4C4086F7D83F946C48C0818B6D40BCB28E40258F01C120146D3F0C8FA7BF871B02C0B87B3A405103523FE101133F32882FC09A59D6BFBFECE8BF13755240DC0381C01A50214034993CC0D3A1ACBF5F388B4091D764BFC653473FEF387F4063F4DEBF2E367640B5773FC0BC32A6C0D9A26FC0D3E0FE3F092C9CBEE90D2C40E0C903C0BE1AE7C03BE2C2C0FC3C02C01F8640C06C57653F788006C0A52648408A9F91C0D8B37FBF967187BFDFC24FC0FBC18340A51493C07869AF3F324A1DBF6D9F5D403DDF1CC04F6C78BF28F68FC092001E408FFD94402F8D25C026EB0BBF69FCA1BF7EE6BBBE8ADB4DBFB9EC54BFBEEEE4BF843334C02724C9BF2CA487BF8340CB3FA01C83406F07F94045880A405C9C6DBE0A23AABFB93B193EB6DFADBFC086633F5CFFF7BF28CC84BFD56528C01B755EC03571393F135560C0FE371B3FAED8D4BF0D1D47BF14F89D3F1F938540B68F10C01279B0BFCC7F05BF9B1D0040DACA8040F9AA5CBE5D8D82C097C60FC01BD0C53F945D33C0CC0359BFC2B8CE40A54443401C7DB23F843A2FC0BF037B3F5AEB293E94DE43C0A4F456BF5343CC3E199277BF7B4C0BC0110F0D3F993CD5BF46797CC095228FBEBB7C553D1DB453C0DFC81240239F20407B548240DAED9640F2E32EC0D6CF8EBFB8FE86C0ED11ADBE220F34C0B3635DC08263623F83DD1EC095E424C068F853C05859853F192D1DC0F669D73F8E43FBBF804A3A3FDCFA48BC9263003F4BD1CEBFD1FF3A40177384BE9E5303BF22F396404677A94030772440538B9CC0DB4910BF79EAA7C027DC4B3FBC61E8BF32BCC23E3F2B143DA83A92BEAB23F33F2A9F193F7C746BC0A8002A40C50A513E8CA239C0D051B7C0E842603FA3D81CC027D34340203A0CC0FB0D7040ECB9EE3ED5950B3FA47AA43E143B713F3A84EB3E3485F33ED8B194C03920A03F0725433EFF9ADDBF8B621DC0A17D4FC0B015C13F7CE787C0AA168B3E38B18C40C4E11F3F909309401230314081C8744088C3FD3FA671D5BF88CB5040EB2CB03F2CED28C0C8AB933FA64D17C079B0513F7FA9613F5893E5C0EB38434007B086C0A827CE3F0567903FDA3DC13F357801C0B507A6BF"> : tensor<20x20xf32>
    return %cst, %cst_0 : tensor<1x20xf32>, tensor<20x20xf32>
  }
  func.func private @expected() -> (tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xC9E967BF492CA5C00F921BC010BBB5BF6FEEA03E809E23BFE5D5A53E08E9A2C028C952C093FAAEC08C04EBBE118F8D400C181CBF4DC35CBF7329A23F443C78C094336A3F93D14F3EC50101BF69EE053F067D1540F52B963B03686F3F10BBB5BFCD2020C0809E23BFC50F31C05A58A9C0CC0A34C0B8DE31405CDF04C07B9DB4C0842890C04DC35CBFE6CE48402C30DDBF48F7D0BFCB301FC098BE83BF9CBAC03EA19239BEF52B963B03686F3F98E0F2BF6FEEA03EE3CB98BFE9B9D7BF08E9A2C0C59C7EBE5692A73F9806AB3F35165CBE6BCDFABF4DC35CBF9B3D51401F6B74BF603121C093D14F3EC50101BF9254A5BE1A4147C0F52B963B1F528AC09A0736C06FEEA03E809E23BF1B0F0EC008E9A2C0C59C7EBE14E260BF9FD5AA3D5E049BBF0C181CBF4DC35CBF9B3D51401871424094336A3F93D14F3E3BA8EDBF69EE053F7D37A4C0F52B963B332B0ABEFEDF68C06FEEA03E809E23BF27B9513E08E9A2C0C59C7EBE5FFDC6C0AE78BD3ED3E5B2BF6B0D94C04DC35CBF63348AC01871424094336A3F93D14F3EC50101BF8549C9C0DAAF8DC0E18E77C0FB2898BEBF4124C06FEEA03EA19492BFD3E4D5BC08E9A2C0C59C7EBE558E25C0E6944BC057E334400C181CBF4DC35CBF5F96D3C074333CBF94336A3F93D14F3E95AF12C09F7F0CC0B47D82C0F52B963B03686F3FB7470EC0817282BF80A1FCBF535368BF08E9A2C01336A0C0E02D0740D7D33AC0C1F4473F0C181CBF4DC35CBF646B83BF1871424094336A3F93D14F3E6EC725BFAF0389BE887578C06DDA40C0BABCB4BE303457C06FEEA03E809E23BFFC59C03F08E9A2C0F098B6C09178864039746B3F9B5A54C00C181CBF1714B3C02D0186BED0EA0AC054AAC5BF93D14F3EC50101BF4BBF733D067D15403BAC70C0BF1B82BF10BBB5BF62D783BF809E23BFB92CECBF08E9A2C0C59C7EBE6DE676409806AB3F13EEC7405A35C9BF4DC35CBF9B3D5140EA7DBEBFDD55A4BF68F62BBD0F6C1CC069EE053F8D9C63C0CA23B5C003686F3FCF5514C06FEEA03E809E23BFA35AC3BF08E9A2C0F16FD8BF4DA08BC09806AB3FFB7CC4BFB47F03C04DC35CBF317F23C0F73CE3BF94336A3F93D14F3EB03939C0364D08C0D606A1C0D6D259C0F871ECBE10BBB5BF6FEEA03E946C48C0818B6D4008E9A2C0258F01C120146D3F0C8FA7BF871B02C00C181CBF4DC35CBFE101133F32882FC09A59D6BFBFECE8BFC50101BFDC0381C0067D154034993CC0D3A1ACBF10BBB5BF91D764BF809E23BFEF387F4008E9A2C0C59C7EBEB5773FC0BC32A6C0D9A26FC00C181CBF4DC35CBFE90D2C40E0C903C0BE1AE7C03BE2C2C0FC3C02C01F8640C06C57653F788006C003686F3F8A9F91C0D8B37FBF967187BFDFC24FC008E9A2C0A51493C07869AF3F324A1DBF6D9F5D403DDF1CC04F6C78BF28F68FC092001E4094336A3F2F8D25C026EB0BBF69FCA1BF7EE6BBBE8ADB4DBFB9EC54BFBEEEE4BF843334C02724C9BF2CA487BF08E9A2C0C59C7EBE917886409806AB3F5C9C6DBE0A23AABF4DC35CBFB6DFADBFC086633F5CFFF7BF28CC84BFD56528C01B755EC03571393F135560C0FE371B3FAED8D4BF0D1D47BF809E23BF1F93854008E9A2C01279B0BFCC7F05BF9806AB3FDACA80400C181CBF5D8D82C097C60FC01BD0C53F945D33C0CC0359BFC50101BF69EE053F1C7DB23F843A2FC003686F3F10BBB5BF94DE43C0A4F456BF5343CC3E08E9A2C07B4C0BC0110F0D3F993CD5BF46797CC00C181CBF4DC35CBF1DB453C0DFC8124094336A3F93D14F3EC50101BFF2E32EC0D6CF8EBFB8FE86C0ED11ADBE220F34C0B3635DC0809E23BF83DD1EC008E9A2C068F853C05859853F192D1DC0F669D73F8E43FBBF4DC35CBFDCFA48BC9263003F4BD1CEBF93D14F3EC50101BF9E5303BF067D1540F52B963B03686F3F538B9CC0DB4910BF79EAA7C027DC4B3F08E9A2C0C59C7EBE3F2B143DA83A92BEAB23F33F0C181CBF7C746BC0A8002A40C50A513E8CA239C0D051B7C0C50101BFA3D81CC0067D1540203A0CC003686F3F10BBB5BF6FEEA03E809E23BF143B713F08E9A2C0C59C7EBED8B194C03920A03F0725433EFF9ADDBF8B621DC0A17D4FC0B015C13F7CE787C093D14F3EC50101BF69EE053F90930940F52B963B03686F3F10BBB5BFA671D5BF809E23BFEB2CB03F08E9A2C0C59C7EBEA64D17C079B0513F7FA9613F5893E5C04DC35CBF07B086C0A827CE3F94336A3F93D14F3E357801C0B507A6BF"> : tensor<20x20xf32>
    return %cst : tensor<20x20xf32>
  }
}
