// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<20x20xf32>, tensor<20x20xf32>)
    %1 = call @expected() : () -> tensor<20x20xf32>
    %2 = stablehlo.add %0#0, %0#1 : tensor<20x20xf32>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<20x20xf32>, tensor<20x20xf32>) -> ()
    return %2 : tensor<20x20xf32>
  }
  func.func private @inputs() -> (tensor<20x20xf32> {mhlo.layout_mode = "default"}, tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xC681193D87491FC0B474344084243740AED868C0A0CBA6BE56A2ABC02952073FF3F14CC08F73283F1549663EB63D30400B4F58BF70E6A43EA12EFEBF963CD0BF896F8ABF8DFC4140EBF9C33FD7E40C3D4606AC40ECB2BE400630B93F495495C0AB3684405DAD9EC0D8ACDF3E52DDE23FAC3632411FA4B5C064DEC5C058B83240C97682BFEF9388C015AD6FBEE200FA3F4F8E3C4097D0AE3F7DE29940C65E65404CF0BA3E68F10CC1DA08FABE8F1E4140C6470F40FB5E16C0C1AC9E401C12A83D7E1C75403D73C7BE8F4847BFCC8C26BF9DBC1F406FF5EABE315EDFBE357EA7C032E5F83F1CA4F8BF8B7714C0949623C010EE32BF108730BFC79578C0823075C085D471BFC4023640277C09C0E1649940CAE0334096783140D669933C9CA51CBE1042A3BEC58BE93F06DC52BC35B999BF2030293F1AD6A23F95FF4C40EF5881C0DBF39C3DC32F094045DD9CBF4BFC223F0A96283F51923140FA8A60C0D271FCBFA48330BDCDC580BF6742AF40736CCE3F9984D33EFA64E9BFD8BF24BF9365F3BE269935C084DF1D40D2A1C640BE8C483F87E289BFD3B987402CBE60408941094063E700BFD06E993FE1F23EC07950C0BE2FEFEFBE83CF37C0CCB6E5BF1C54C1BF1916D8BF719B95409BBAF1BE938FD5BF408ADC3E3A1BB13FFDDEAABFEA1765BF47A044C0DFDEBB3F4014ABBDA3892840842882408F951E3F115BF73FEAD6CEBFF8366A4029D2223FDC970BC09757C54094960CC08C559B3FD596103F04978AC02F2B2540A6350DC0DE170540210D623F45DEC3C076956CBFB7D64B407673AC3DC2240640DFAF7D3FB06F0BBF05BDD03FD8792F3F493F0C4062C861C00FCD76C0EE9E5CC051FB9640E1EF76BF7E18F9BF520059BF9BE88D3FFF4A3E4087AD8BBFA54F3340FEAFA9BFE88EEFBF53E9334034D4673FEED60CC06DF781C02CAA6CC03CD0BE3F2B88793FAD1523404E0A224029178CC071558EBD3C2ED9C0CFE6A83F8475F13EB8E1473F70971A407070E4BFC6252CC0434F0640C99E40C085139EC0F0BEE03FB9D755C0661753C066E78F3F9B4D3641A8B1CE3FDC5739BEA6D746402D0257BF7C61E8BE6ED13B40676CDF3E9386AA406F255340BB716FC01C7FE4BF4A59704011C84FBEE225BEBF7A291940606E263D479F8040AF9719C05A2C17C00002ACBF912C19C0ED3B44BDB97A21BE030CA7BFFD100E4096764A3E390890BFD8FE0140A8552CC00525BB40202C3A3E4C11C33F5B0184402DFC98BFC1E724BE835A50409456F0C029358DBE3D9E6A3D14E98A3F002252BE100C3F401747E9BF0227D5BD932AEEBF8D4E0B40E1DB0641499F2F408D3DC63F1E803940FD2FD4406D05F33FDD2FEEBF5AB19EBF98CF89C0BE65EFBFD71AD63FEA877640ADDDAABFDAD8983E100A2840ACF2ABBEC19B803E62D56C40435426407F24D0BF3A83A2C01F947D3F5B91B13F16CD87BBDAC1A640DE8972BED9DBDB3F19BE47C05B32194080FEDFBE4CB727405B1520C0329ED5C0F12B0AC0CDC0933FCF8130BFD74F3E3F313D9240C6BDB93F1681A13E5C650040D5CA3BBEF4426B408A022DBF3F5FEABEF954373F78D1A43F4DC0A5BFC974E7BF06A261C07A30F2BE7B35BF3FB72805C08EAC7C40481B96BFDB1A8BBF104E5FBF95D95C3F475D59400D2989C09DC46C4089AB033F3D222ABF7CA3C2C006B5BDBFE83E8140566380C02D1700C0EBE859C0AC930640319442C041F506BF8932B23FCB417BC0C911A0402A761C418E026D3F51A87C40E64A46406C87A53EEB079440F8183FBF856385C0D61519C0613714C0132FFFBF04A425404202C540A4B28B3FC202D93F90F17FC0F9FAC840F64F0841A0036FC0D1E335BF607B8F4066DA434012B391BF5C7701C0F3F499409BDD434052603E40832404C0A8169F409F53793F09689EC097141CC0A732114036F1C7BF7C112940A8C6094038D422410DA1C4C0FA2BF4406881BABE2A932340FCAF56406ECA3FBF733C92BD1F4157C0658C5DC0759BE03DD2614F4076785440D8A1803F479373C0CFF1DFC0002CB43E4B8EE3BEBCFF773F643F0F400FB9BEBF8B47B5C008724BBE2C5FD1BF79759FC0616F85BF8CC65D4025327EBFA67E8E3EA51368BF039AC33F1D9501BFC081023F2A915A3F7FA2C63F880132C0E763DF3F3E9508C0D906A5403C8757C0C1EB09403D1A75C0D36F333E3EB9EE3FA2290FC090C236C0DF925CC0FA031840423EF4BF060BF0BFE44D88BE6FCC8540761506C0F4927EBD"> : tensor<20x20xf32>
    %cst_0 = stablehlo.constant dense<"0x1BC3AEBF0F667F40851C3340A51BE9C0F20FA53EAD115BC01FB1CABE6DB9F8BF732B893FF9349EBE6AED8D403B10874009729F40FF918BBF889390C03C58A040FE40B6BF833F62BF2ACA9BC0463F24C059779AC02C80B8BD177F09BFFCFF0740712724C0D544013E918CCF3F44B72E401C5F2A3F4CF023BF3DD0BD40063B3E40B52606C00DCCC2BF7ECCB0BF0A8490BF12788D3E3470EEBFC1F7CC3F15CE243FBA4B8B4045C9A5BF935094C0EBB50240036C55C0CBDEA640F74B43C0700D08405722983E8717723D9D80823FD92815BCC849F04048D8D0BF685D3E40FC148EC024CCF5BF140468BF3D9A2ABFF3F28A3FB89FDBBF5D8D913F2833E33F07FE67C0C73B9B3F1B9F2640F5AB554047B1DB3FA6E75B40F8CF49BEB127BEBFD77147C0ED3A8F40A728BB3F261D9540A2E1C7BE9833B9BF9388A13F95FE7340CF3087BF1461D53F94C8B4C0B02B8D3F613E41C089864DBDC08A813E940663BF92E2DA3F6ABB4DC04DC918C0E922FE3F6F9A89C05956CFBFEEEB353FDF81DEBF68EA38C0E24941400F199B3F812A543E1998833E776C6FBFAF91BABFAF16A0BDA3E63040F2E080C00148C43FD83400C02CA9DC3F6199B93F04D382BE4D7EDE40F15FA9C0B4AF1A40F0FAA1C0C0BCAABF770F61C06EC26CBF4CDD03C027B1903FE556C0BF55EF77C078F77A3FAC673FC0D0B36040860EF7BFA296E7C05F3D72405FCB07C04AF324BE085AB33F8049F7BF64B51B3FBFB9D23F5B02AEC08F4AB63FF0BFD93E8D1D75C078EE2940198A35BE8E2FCDC054E60D40BD6256C0ACBB20C048E0F140D8540BC1B709A03FF4454EBF8F6B8C3EAA16E0BEC4A599BDD1DAB340A25CF6BF218D8BBE441A4C3F7BF1C7BF0461D53E60DC8A407B58BF401462A03FA4E4E23F1A019D40D3E95EC0F2D95140FF5B153F496BEFBF52E267BFA20B1240936A053FFD1C7EC05CBF88C034DE96406F1BD63F58A71B40632663408FAE1EBF2171C83F4FCE343F09444A403891D23FD1977E401C113440691537C06FFF84C0F4DF16BFBCBF56C0AFDB1D408D4F8640DC55A3BF67BDBE3F82F3DEBE804FD13F5BB83740CA877DC04B777B3E3E1C43C0E6B6D5BF9BFFF4401C2F7A403D449F403DC899BF4115254015BD943ED4EA614015D866C0708F9FC08B4E0FBFED4EEDBFFFE218C1992E43BFDE77123E0DE82C40109915401F6E58C0ACC83AC0664305C197ABDEBF0ADD9340B683F1BFA764B2BE013774404BC47BC02EBDB3405A050BC0315437C0B9410A3FCF46BE3D9ECD8ABE15935B3F02691CC0F73D1540843BB2BF5325203F21A50A3F2A2365BF7E64CAC0B4D42EBFA79061BE978A6FC0AE099E40E5564FC087E854BEBDF050C0854C58BE871F9DC0C346293E259BF6BFEAE282C07A9A67C002E21240EE873ABFFC049FBD5D77F13EE68476407ECC863F4D3799C0A9A84CBFE8C59C40C993E23DF876E8BEAD1619BE569A36C0816A7EC0BF8C3E3F4FDB8ABF813CC23E6122FCBF612B76BFF06EC33F66B6153FAA06603F6D9D0340691D2C3F3E364940597F71BE81ACC93E0ED59D409ADFB3C08D9965C08020A3BF1D9F2F4041CE1D4072AEAE40FA0B413FC09BC73F8C3A1E40F560A540FFF587C07ACA1F40EDAE73C0C357283F982EB43F8FC0CDBF171A0FBFE495E6BF137FB6BFA339263D36F34FBFC53B914027BB834095D383BF250A9440B0459CBF2E78D13F42A0A53FA6880F40E6EB22BE0BAE054099012AC075612FBF6C49BCBE1564B53ED4F49FBF21E1B7401162433F6D89B3C03432044037793E4016E40B4094D6A53F8B3783406B7D56BF1E5B1940E5EC76409154FF3FFD0984BE86338F3FFBAED5BFDE028AC094E8B7BCCD69AF3FB125D83F410BC63C2A1131BE50EECABFA41C804078F68540CE9B3B40141B19BFFC602D40D831B73FA68505C03F9172BF1CEB02C0237EB13F02646F3FA4938DC02CE8633EEA77C63F2B054840109294C0BE8F1AC0414028C0BF0946BE3C6CC4BF3864B8C0C42809C09ED21A408A7E56C08BBC1140922F1F404429FE3E1D91F83F85B10B405DB90FC0E90E4C3E19686B3F3C618EBF56AD6DC0192BBE3F7A0793BDB0EC29C081343B40B0E0313F95E8EC4008E91E40E2AC07C1EAC0053E5DB00AC0BA1BF93FBAC696BF74AF7F40C8809EC08CACC3BF976E15BFA3B996BFB38B303F07154CC05A71F33F824486C09D571F40F1DF063F54ACB1BFE72C94C0B6222BC0844FB1BF1620BF3E13BEB1406FA3F53F1C11D63F30B2FEBF"> : tensor<20x20xf32>
    return %cst, %cst_0 : tensor<20x20xf32>, tensor<20x20xf32>
  }
  func.func private @expected() -> (tensor<20x20xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x0DF7A9BF1039C03F9CC8B34063898DC0B03654C021EB6FC0684DB8C05810B5BF3A5C08C025B2B23EB31F9540162FDF4028688440C6B044BF301FD0C02D925840445820C0AC6C09405E9755C0B30B22C068770C3FEBD0BB40F5E0683F96A822C0CA8BC83F36A39AC0E4BB0340F61290409EDC3C412822CAC070E280BEAF79B8401A6247C0F246B9C021C2CEBFB0F9523F513D4E40747EFEBE6D20CD4026498740BFFA964091AA21C121F1A3C03DEAA1407A488CBF9B5E3740161BF43F014E0D40641084404C30A9BEACE2763E6FE128BF0B142041D2CA05C0A271224098C91AC18043C63C135336C01A1E3FC0353ABCBF608B1AC05427E53E33FC06C04497EEC01246893EF050AE409C5F983F3351D04038E4C74096DB24400ADABBBF313C51C0CC068540365A5240B8B394409EB1CBBF103749BF562F2240157FE0402325A3C05230DF3F656160C05019FBBD4E7F18C0A1BD1B3FA9C3414050A68CC0003D86BE797D50C0342C59C021CBEE40A4FE2BC033759ABF036F8EBFE67018C01A5757C0C00B3B3E0C6C6B402643CD40652C853F61CC00C0CE2A324077BD5B4016149D40DEFD90C068DB2E40DC939FC00E95AC3F2A3B7B3FE42948C09A10A540F8B4D9C09E923A3FF0F7C5BE672BE7BFA0EBA5C09CFAFCBEBC3E2DBFB06E51BE6D7119C0CE47DEC04EAD1C404EC044C0BA9EC440C5C90840F0C3D3C074F5B640D4366FC0C3E75F408E6102404E9E83C044CED840D2E60CBFF82C87C0FA95FE3F0AF679C0BCE49FBF90C6E53E797EF33FEAEDB0C036D679C00DC488C02C6C2C3F1692F4404F97D3C0D3700F40D2DAACBFE9D7F33F0CBA7D3E1B72074040ED0540B0FDB8C092106EC09A7EB040B6B421C03DC0C3BFAC785F40A2D2E240043E87403A6E2E3FECA8F640E9E099C0FC24B43F534059405E0277BF82CF46C070C6E3BF874F4BC0DFB41EC0AD1C53C00A69E840038C8640F40DF9BFB7B35E400E04EDC0F8AB384088C4963F773C7C4006F08140995F0C40C06AFD3D981843BFD44EE5C084EFB0C088C0CCBF28F05FBFD01E663FB0731BBE48254E41C8F4963F8424BA3F0048BF402BA499C0AD4B55BE005AE9BDCCDB9DBF17C34F4146AAE6407E2D9E3FAC233FC046B7CA403264B33DE3D70240365D9BBF93429EC0EB6A5D40931F88C016AE3EC1A6CC06C0130510C01DD7294064810B4010FA95C0BCDE32BF8C1902C1E85937C076DCD440C28B92C0BBFEAF40C3D97F40A53B1AC044DF1B41708357C0ADA241C0F1EA7240795DEDC064010CBFF93C6A3FF0E8ADBFD71B08409CDCCB3F6E3499BF8200E03E145E30C038BD84C02CDDF7403F862140D06B0CC0BDC9FA40150959405C68D83F5604A4C0EBBAB9BF907713C1E63CDABF380182BEA0DE73BEA8849EC01DFD254029D0F23FEBB3D3BE8F09393F24ADF14082BA69406D40CDC04F18BCC06C78BC4098BABF3F2C96EABE25F9A140F4C245C0947C10C0E91A18C06789A73FF80F6EBD6E98263F33A05DC076C2A4C0AF7CC9BF11E20140F2F9AE3FA036B53F50D8F640DB8D9B3FCC96353FBC07DE40F1BDB9C0E02CB53DC5A1F9BF355312407FA34B40D0E2D740A0740ABF48C87EBEF4CE86BFED3D9640405130C0180ED53E10DA0F3ECDDE03BFF44EA43ECCB31EC0FC7E9B3EAA24CC3FD2C8B6C0845D6F405A8F98BEFBEE774054A1FBBF4EC420C086A40A41C274A7C0B0D8BABECA1807C0290E8B40EFC24CC076E1C73FA9D0A1BF148D93C0324D94404B21224134CEA5BEA51A1B416A237740F630A9C00521D640F9B20E40E8C5FDBF18558CBF6A6FE43FE43635C0917F9F405A3C20419A8345404300B83FCD5738C03A8F93400E9D8640717370C0C9EF283FCC84C5407D66454037D5A7BF84EE66C0CC080D4146E5E74010FEBC40486B2AC026C7F540D4ED1940DC2AE1C0E7B858C0B078643E989833BE7CEA6440A06011C0D9632641120393C048172C41263AA0C0C036103EECBE393FDE4C71BF0390CDBF640212C1945AB3C07AD721400097E3BD801AB3407E805F401ECE53C088CDA1C005372240262B2CC0BB81953F6A194A40268D26C01B0F16C1D8BCA43FA48FDABFD16BF4C0A1F9F03F5C1F85405022CD40DDB830401C2E16C12052D43FA4152BC04D2E1D4094F8A5BE5A80B1408C81F7C0D8BA5D3EE4F02DC0E0B07E404F642BC08C5284BF20C3F6BF03A980C01E5A8B404CE3DABF5DCC87C02B3B01C1E0F598BEE3C652C00043C0BF3539A9404B35C3404067D8BE645303C0"> : tensor<20x20xf32>
    return %cst : tensor<20x20xf32>
  }
}
