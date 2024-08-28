// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<1x20xf32>, tensor<20x20xf32>)
    %1 = call @expected() : () -> tensor<20x20xf32>
    %2 = stablehlo.broadcast_in_dim %0#0, dims = [0, 1] : (tensor<1x20xf32>) -> tensor<20x20xf32>
    %3 = stablehlo.subtract %2, %0#1 : tensor<20x20xf32>
    stablehlo.custom_call @check.expect_close(%3, %1) {has_side_effect = true} : (tensor<20x20xf32>, tensor<20x20xf32>) -> ()
    return %3 : tensor<20x20xf32>
  }
  func.func private @inputs() -> (tensor<1x20xf32> {mhlo.layout_mode = "default"}, tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<[[3.18015194, 1.45297503, 3.72370386, -5.869150e-01, -1.62054098, 0.395547301, -0.301555574, -3.34591198, 3.41248298, 2.03225017, 0.179800764, 1.51023889, 1.80594838, -3.82093549, 0.991148531, 4.21542788, 2.70781755, -2.65522385, -5.42288542, -1.35036302]]> : tensor<1x20xf32>
    %cst_0 = stablehlo.constant dense<"0xC5222B409A6ECABF04721CC0B26288BEC0DC0840551F30407D2F82BF98DE81C04BF9B63FD6313C40223B213FC4E93840F2C0303F5674CABF04CB113F822354C0A71D4EC08E5549407FFBC340E91F8CBFFEF1823EC54465C0B96CD6BF234B7540C66299409CBB84BF2C754840CCC375BF4E42ADBD99B7BCBF136B08C0F8828AC029CD92409E91EF3FA8235C4006AE7F3F0EE05DBFD0DFB33F2E80A2405C1809BD3F046C4010D83C4009E36E404B4813BFF4A10DC077BE25C09FEA84C05B7976BFB23FE43FE5BD4EC04950B23F664061403E9A343FF6DC4A3FDBB745BF46CF59403897613F3837A24074406DC019F96F4079A820401869083F3C95AC407687333F7D0EE240BA4752C064D5C5BC60386DC06D40334025CFDE3F2D2D0C3F7D706B3F84ACA9C0549A773F77C34CC08C6565C0F9B8C63FDFD918C09FE96ABD87671040362C7CBFB90050C098E914C0DEB328C06D8623BC627186C0654B4540172F2D3E9BC66EC09A31ADC032BCA4BF1A220BC139D23A406570593F6B28633FDA62D8BF77D54F40E8CD1CC0D42EBE3E399D7C406C7B3C3FE6267EC0A647F33D0FF3394078AB4940BA10D3BFA77236C0D2BA7DC0BEA72A3FBDC3C2BFDD0D1AC0BF9474C0C08C35402AA7FC3FA7E0883FA2835CC0B1378B3FF1C82340CAE61140B68A3ABFDFEEB8C0EE46A0BDD3F672BFF48B6DBED99C64BFE89940C0164994409AF433C0E177833FAA01A2BF5B9E33BF1495B4BEDA9899C0CF4B03BEEB4063C06E2789C0FB7F58C065B066C0895EC8BF82185BC0D288DE406EA708C0BBC6454095342FC0F06C15BFD92E4F3F7F758D40438426404C3FD0BFAB8BCDBF618512C0CEFD71BF67050D401AE3D23FF31BE7BF1935C7BE2EC8F53F1B6F573F3C7681BEDE5DDD3F880DC1405FECD1BF03552ABFDB27533F7FD3EEBFD21E0BC02ADEB340B1B580BF738C934000E0CB3F41A885BF957AACC0FE04A8C0D08219C0A1A8403E528D41C0013F33C09B67013F1B3D4440141473C0FADE1B40277AB2402787623FFA97AB40D0A5FEBFC32DF7BECD2851BEB22AA5BF91A0F13E1CD60DC05EE3CC3FCCC00541CE792F3F1A3403BF9DB65EC0F6FBA4BF02F53CC0076A8A3CE2B83340BE5C6DBE85C2833EFC10A5C01EE6933FB698374098DAC4BE65938C4092593B3F3B4B874011E342403D7EE23FD323693F457DC2BF987BBC3FD5AC3EC0EB0C153F3C6FCA3FD7F0313EF7C86DBF3F3809405F1FD8BF453CD8BFE10FD93F3B140340A52839C03FF54240F0F37E4065318EBFEC61774064B34AC0516603C0406B4BC01FA3D2BF0EC3C43FDAB671C06313383F923C3CC0CFF28BBE296C0ABF80B87E3F23F8553E394358C0EA78D93F2B9CC13E789CCBBF28DACE40250B9FBEE6A783BF5C9D2A4058B27DBF526EC13FD4881BBF2EF602C17B9839C068F376BF69B17FC0FA4E54BFB7F08B3E38846D3F96E5C83F28A6BBBF2C816B3F4474E13BB62A07BF6C383F408726CF3EE5BAFF3F698014BF782BB9406E1E0EBFBAEF06BF498A1EC0BB9F54BF47ED99C0CFB959BE79AFD7BFA1B32FC0A0E13940806A753FB132DE3F6F4F5840853220C0079E513F517FC23EEF8B88C03D9C8FBF956EE33F72B080C0C564B7BF0AAE6A3FD41E52BF9FC938C0F87E8540E192D23F95BDC93CBF65C9BF7BCC0A3EE050D1BFC2EAB140310F79C0DFACB43F035308C0DBB10040BB7608C077A2813F0BCFDFBD80CE0DC01B0CA4C05FA08440CFDD2F402E120B403BEAABBF8996D93E8BB27140775D75406A557D3F10E8FF3F5206173EDE69BDC05C853E400E8A6AC0342F96BF16C713C0D1EFB13EE79D963EBA0B1D3E6DC9EC3F1D97B53FE4E38840CC5ED7BD50EA2140592E7C4016F18840987B64BD4316623FBF595FC0F6841DBE32244F4058EE09407E6033C0814DD0C0EBD82D409FFE6D40589F13C046F9444022B0B83F21D98D400F2B21BFDEA3E7BF7C7F4CC0C36F453F447568BDDAD25440B7F03B40B670C0BEC2456540BE3D89406497C63FA7EA7CC00B10A73F922524C099615EC0556E2E3F818E883B796622C0F99AA9C002A02D3F51D6BD3FF1709840D0BF513F88BEC1407C88C740635908BF8DBC23BF77EA7A3FD1853C40D2F3453F667B77C0AA9D874099140B3F35E4BA40296931403EBE8FBE893F8CC08AE4B9BF9ED4F8BE51838C3FA9ED4A3FB92BE63F63E3EFBF1713EBBFECA53740C64B37409621AEBF1E788ABFC95A74C0B8803B3F3FFB6A40F6AC93BFE3D11DC030471B40"> : tensor<20x20xf32>
    return %cst, %cst_0 : tensor<1x20xf32>, tensor<20x20xf32>
  }
  func.func private @expected() -> (tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x5C93013FD83442409761C5406E1DA4BEB29370C0AFCE16C03B2C373F1067363FF3D2FD3FCC8568BF6C67E6BE0684B0BFD8C88E3F0A500FC0CAE1D73E8AF6F04044B5BD405FA2B9C0E3C138C124E382BE5C293B402821A140C3C3AC40946D8DC03F3ECDC0E75CB73FDCC15BC079B218C031D05F40306C6040EEEC1340D8D6BA40AA0532C08229B6C0AEB41CC010DE4D40E6C464408CEF81C03A0428C1EF8FA8BF8CF201BF0AB5BFBF00DF11BC40F13DBC0AAC173F1D0F3F408E887640158518C08C8CD03F2467A840934C9BBFA59800C032DC8C3FB9A093C0E2B9E13F30E94F3F28CEE93FD02EF7C034A0DBBFB932A3C08C7C2B3F148D6B3F9CB2D5BFC3E3A4BFFBF40AC160986B4028088EBEA0A7B83EC8961C3F8446953E824BBCBE872E173FD876E340653899C0391986408F97F940CBE0933F88AA88BE74B2ABC0E0D366C055498540227F9640619DC140DA230340D626CEBFB5199340159858C05DF660C05D96E440CC39EE40E8BFBB3F0A4C2341217B8EBF277395C0F09BD43D80FDBC4054220ABF801452BE346BB9C0C984A9C0C1681C403892AD40EDB6664013835FC035B198C003D90240F7252340985D1E3F30BC2F4042726340B88F2540409EAA402FF083BFE56EB9C0282BA0BD9A26F5401362CF3F10DCA6C0AC7BF6C0AE261FBF56590F4185FFC33F6F87954026BAB5BEED3E3ABF8EEA59406EEF9DC048BB08BF2EAA184038115340C7A5613FC774EE3F2E63D34078556CC0F35791401C0608416EE6C240D404733F4AE176C029AC0440088A71C0F9A46540BC29223F91A409406BB784BF85D8D3BED71B97C0D853BEC0E242A14038D668403C071E4034271D40F485CBBEE1FDAEC0F4FC32401B5893402CA3493FF7CA5FC0E370A5C0481B45C0749336C0BAF3454035738C40F6B3B4BFE02C7B3E786F24408284BDC094C815C08E6599BF1803E13EF7AB9C3F76CEDC4052CFE140CA0EB6BFC1914D3F72ABE740F245B04017494AC06AD307C1BBA71C4088A23E3F62FB83C060AF3540FC5FBEC0B4DFBC3E78D9603F5E44C7BD138E03C00D323C4040F38740A8DFB5BFB82DDBC06A6C8F3F2EBD53C0CC128F40C623B040F220B54004042BC05CB203C11A2D8FBF4B0F3B40C28FD3401B5E2440BA285DC03D379EBF24D67FC0284684BFF15CF2C07018BC3E248A863E671C3BBF64E64140E4B6AA3E807557BFFC5DD13EF4912840D52D2240E4F9DCBF6624F2C0B41AAD3EDFD29B4058A678BEDE79D63FA1981340185695C04AA365C00B304F3FACC2E6C0C28CD2405ABB82401BED564050F949400C99893EC0D634BD0C518B3E1203E5403CCB3E40265407C0575FCDC0B697C7BF6AE5D140A0EE7BBEA51D5640707C803FD05A01C129C8343F0D1D3A3F6460C0C05AE98C40E864053F4090493F1E201B41929696405BCD36C032909F40A86EA140CBCE1B403E5065C0ACC1DFC060D7EC3D51A71040A219B93FEC0D884070C864C0C29B01C09A19CDBF549B8E3E971E12C1BAED7D4052CC2340240C2A40B0CF15409BB7D34098EE66C0B7462B409ABEDE40E04B49BED04967C0F314E5C0E45D97C010DDB5402558223F40015640DA876B409846FFBE4ACDB0BF34146E4013E2F4BF9CBA1F40189836407A4B44402F562AC080B3243EB01D76C0DA212440658E8240A9FA8A402D7103C1BA02C4BFC8C230C050EDA94040D10EBFF263BB407FC2CCBFF270C1BF261F2740C3659A4015B2EFC040212A3FB01C10BEF1EDC23FE0E98A3FC53BFCBFD6F3F4C000FECC3A8AD50D407DDC23408CE450407A6506C1B51D14409B4F8B40A1C4704030135840048F61BF5A0FE3BF2228BABF7C30DCBF9AF5F3C01521614068CFFEBE7EAC70C06B3A31C02E4DEE3FE38796C05D648F40F1D08B40405D07BFC4EE99C010B027C05417A5408875ED3E140111C041F8C0404A896AC0020F44C0CE3081C0A0F0A73EFAA2C4BFCE72D340E468A13F023B723E3256E8BF1DB890BF1E7C5CC0C8D625C0403D96BD6002943FEEF6A53F4A4CD7C072729B3F9AF4D440D787453FE30C6E40EAACF93F007F6B40D7BA90BEB06FE4BF54C101C12BF6254056B680C08EC7C1C01ABE0240CC831C4069A299C0AE2DFABF9E4C5C402464D2404295DCC0DAEABEC0621AE6C098F3D03EA6EADD3F0FB4014104895D3FBC3891BF0CC433BF34108CBFA49CA4C0E82BA940EE99774011242CC00A48ADBF74A54A40264E2FC0E2E4994064E95E4074B976BF6A31C0BFAB3E3DC089B371C0"> : tensor<20x20xf32>
    return %cst : tensor<20x20xf32>
  }
}
