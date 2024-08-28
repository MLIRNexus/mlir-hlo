// RUN: stablehlo-opt --chlo-pre-serialization-pipeline -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s | stablehlo-translate --serialize --target=current | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt --chlo-pre-serialization-pipeline %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xcomplex<f64>> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<20x20xcomplex<f64>>
    %1 = call @expected() : () -> tensor<20x20xcomplex<f64>>
    %2 = chlo.acosh %0 : tensor<20x20xcomplex<f64>> -> tensor<20x20xcomplex<f64>>
    %cst = stablehlo.constant dense<(0.000000e+00,1.000000e+00)> : tensor<complex<f64>>
    %3 = stablehlo.broadcast_in_dim %cst, dims = [] : (tensor<complex<f64>>) -> tensor<20x20xcomplex<f64>>
    %4 = stablehlo.multiply %3, %2 : tensor<20x20xcomplex<f64>>
    %5 = stablehlo.real %4 : (tensor<20x20xcomplex<f64>>) -> tensor<20x20xf64>
    %cst_0 = stablehlo.constant dense<0.000000e+00> : tensor<f64>
    %6 = stablehlo.broadcast_in_dim %cst_0, dims = [] : (tensor<f64>) -> tensor<20x20xf64>
    %7 = stablehlo.compare  GT, %5, %6,  FLOAT : (tensor<20x20xf64>, tensor<20x20xf64>) -> tensor<20x20xi1>
    %8 = stablehlo.negate %4 : tensor<20x20xcomplex<f64>>
    %9 = stablehlo.select %7, %4, %8 : tensor<20x20xi1>, tensor<20x20xcomplex<f64>>
    stablehlo.custom_call @check.expect_close(%9, %1) {has_side_effect = true} : (tensor<20x20xcomplex<f64>>, tensor<20x20xcomplex<f64>>) -> ()
    return %9 : tensor<20x20xcomplex<f64>>
  }
  func.func private @inputs() -> (tensor<20x20xcomplex<f64>> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x88F7CCA335EEE63F50314921212D0E40C7F1A1C1AEA2DFBFC4A7432D336C08C00DD40E5D8C35F83F8327EEB95C1AF8BF76A3D6D600C5DE3F7E26293D7E0AE5BF3E6CC9C05FCDD63F88768E080FA8DE3F71A24A635583A23FF5F521FA633EE5BF466F52D5C2F1FCBF52F35EF64F11ED3F04C351294CF0E2BF67BA4AD93A2FE63FDB47DD10231910407B5819FD78C0B7BF8FFB87FD7215CFBFC5BB8B44E01F184060A84334BDB7FF3F9E993194C45B17C0E6BCB4D99B48E53F52F223BDAB9AFB3FCE3E407BD7E6E23FE4E6DB2BFA000D4080FBCFF850171440A97FC6524391F23F6A2E3DF02DDA05C0C9760F29307DF3BFBCB064EE5430C83FDED79D03D2630B4069649F552438D73F75F9CFEA8BD801C02DA3C3706C6DFBBF30EE75012269E0BF98474BE3636B0D403020C3371F67FDBFBED803B2EB4E06C09A8A12384509BFBF6C5ABD2847B9F03F1AB1D708F25808C0E8C85FAE00140840D702E75B8A8AF53F62E4BE385576E93F14B61DAEFCCFEC3FF820BE28AA62F93F4E1AB9156CEACE3F847DE3B4CCE007402E3426D3BA46F1BFCDC34EF23F73114078DB4D4BD9BDE8BF284C36B0EB9E0AC0EBFD239673050240AA3FDBFA06231540FA677A2CF2C60A40C6E8E4C5B589E73F8168CF2B8969F63F92C63BE8AE3FFE3F805466DCB6F1D4BF88CBC5EF4E59F73FC582322AE29B0940608069C3A9E0EE3F64881EE2D09DF4BFB589BF8CB88DF9BF9115B8F4912F0BC06E64198A0E68E7BF1FD9F5B982560EC044F9ABE36C1ED2BF08E85AE5A8270CC02C3B986FC03BFCBF41ABBD0405E8D23F2E049B89A075E4BF5073E4DE5502CABF3ED3B01B02C40B4054DB34362F81F33F9B4AE9311FAF13403F35C9954B9421C056E36EA805DDE2BF74BC27970CA1014091F987EF8D680C403CA1A1E5C7DCF23F444005C53F1E05407E3A3340B910DB3F06C45AD5E87F12C012676E55A1240CC08C2D2DA4CF1105C0FCCD20701DF712C06CD541FB368BFABFC35EFD9EFCDCF6BFCE51ACF59C57FC3F5CF494045AE7ECBFC6250CEB7E6EECBF4BDCF894A0B611C01CC0860081EBF23FA67536A8799E1040C128924C844FF7BF144B88008B03DA3F88B4123AF24AFA3FC37AF1FA3A9C0140BE5437826FC71040BC82C76D3115FABF9CEACBC962F9C0BF762C1018F79CFDBFE8E01E35679DF93FB09B684F73660140EBECA41A73CB114090B92783D6E2FE3F5FA5628E59F10940FE6A810FC70106C0007FEBF303EA15C04664AC47C14A1740481A53C22E4D114074D442B77A5BF83FED9747271816E53FBF56AEFD3651FCBF8A4C38B318AFFF3F58116645C1380A4098B261528B55F73FF42BEE9CA1BAFDBF0EA2B5D3B83A0AC0A5FC95CF706501403888A739C617FCBFF8951A159A8B0BC00A636CEE115CCF3F924739C9303D0940D3A7E40AB2A819C049BDADBC3A90D3BFC86DE71E369AE33F3E354967EECDEB3F0A3BDE78202EF13FA6B73686C7CAE9BF70CDDD6809600340337330FA04451540F6EFEB7F843012C02CFA659D75EB08405C5E8FB6887511C05A0B3D2E962DEB3FADA1B31C1AF905404A7A2258C40511C0DCDE5121C5A4DA3F19CF9B538B8DEB3FEEC3E0FC3B281840697CE7B01B7AF7BF14F538795A48F93F9CAF70FF9507E7BF12D026745EC4F23FDC98FF9A6173F9BF209126A62A9DDBBFD6139AE21C8819C0E95D8E89D1A1FEBFF50E4D1CBFBCC93FFB67ED67ACD0D7BF34FC82A584C4EEBFD32A0B8D9A89FE3F85FF580A3DFAF9BF42AB6B42CCBD0A407FF7D289DCE3F6BF7EFDF17F5689D83F9CEC290B04171140F9FD9536468E1F40A7D70DD8E35DF4BFA1D84424A4BC0CC0B6C3088E5CE80FC0A44CEB60FC330A407D812C775343F1BF1652AD1A12A101405A7F05DD449BE5BFC7B9BED73A2CFEBF0F9E5DC3959110C01AA68A57395B1340E41D5DC6B9C0134059CBDBEC3C0BFC3F33DF409DF366F3BF9651110E1F14D93F4E746E189CBD07C02A8AABA5937ADE3FADFAB6A3B96114C058C8B00870CBFA3FA7441682E5FEFBBF7957CD7B108EBABF630A18B73D3FDCBFF8E8A639D446FEBF056940693123FB3FE0EB2D245231F8BF4C3D575348B11240208B123BD5C0F7BF708235E0489BF83F19E2B289B9DE1AC06CE87686D4A4E8BF7BE95D396280FEBFBF715564BB2BFF3F9FA0ED4D9E90F03F0FF1CC92D826FF3F20709344C5DDF6BF4CDC0D2300F70CC0DD6554F62B2A723FD275EDA76E2995BF13851E23776206C0F27F11C065D7D8BF8593E9FE84DBE93F14191155EFCFF3BF6C60B9DBC72F00C0B427EA28ABC3EC3F78494270B9E0AE3F7BC9E29491FFF53F6B10734C2F2C14C01EEB64C24C520AC07ED5D63F2E34F33F968060B818FAEBBFA884C8F4B759E53F84A5FAE78448E9BFEECD99CFD239EFBFB23ADD3B178DF7BF560E89EE949EFD3F323058DA4301FF3F09E6DEB7071E144058E0F59A32E60CC048DDE7D59B9CF8BFA1639784C47A01407A4B250E61E0E23F867A53DB8BD017C0CED47B5F14C4F93FB500BB658FBA0540DE04824F5C2CFDBF647950C6F39E21C0EAB49FE93731E0BF43ABE1F949E8D0BF15A63F03FA800D40A08A7229F8120DC016DE09DBE36E0CC09799BA4FE512E73F2DF9DC4EA568C53F02BA4A5226A30140CDC47891EB7BF43FEDB56EFA9975E63F9647C614144CF0BFB2F474304B5DC6BF78F05089EA4200401AF6A73C0A06F8BF911C6BB7423307C06A2EEBE0E61B0A40F0A88E7DCE65D2BF627F4FE90E20B9BF642792F2429506C07C797BDD7E4F03C05A9689140ED8E9BF42E7F758D1C4EA3FFCECF639420FC93F69B6957564030940E74AE88AFD8BFFBFEC3314E2B925C5BF87A962B149AAF1BF32507D97E46C0AC02F64B1EFC10CD8BF03EB5C8108C2E23FBAF7E66D90D907C02AF5E9BC452F0340D45DE38234511740E264F1E436EC194078B5CB336C35983F147046D0B009E33F55402766772D20C03CD16875A4B311C09EF70C4B13F212C0B0F3243A3679124085642921563FE43FFD63C8507D73F13FC91C048E7B9EFF3F72E82363B72F1740FCDD1B5C74BEF93FA66EBFAC10CDFABF512D6F174801084099BFA2E302A6E03FBD5D47A0DF580FC0C973D4DA8CB3E03FB7F14D484F9FF33FE6B2210C1BC900C0F16659EAA3AE11C0DFAA20B581B1E23FD37037A7DB1CF43F121215C5258E0240CF838D47FFF005C060ED6ABE52E00FC020B66C36A011F6BF5AB50C18C1FC11C09A6C1296BCBB0A40001970F85BE7E1BF28C9D096D756F2BFF3EDA60D9C951240C874F0920B8AF73F6AC8F9FEBBE3D7BF30006EA44E7BF53FB0BBA852293BEF3F884E99F7490A00404A01945ADC8BF13FCC0E4B6DAABC00402129CF10BA4403C00F8606306812024078A23D321544FF3F0B5D652452491140BD758BF010ED0CC06620F6E759EADEBFBFA476CCFBE6F6BFDB3632CA14BBF13F7AD35B1E7DBCFBBF4389E56BEDACF5BF57AF1E59539E07C0E8394F6E71C110C0CABD861399A0DBBFC61156111D8DC43F7CBA54D5D138F6BFE5AE5386ECCF074027C48B8EEC0D1440744D5A98E34CF53FDE15B8E5779702C02AC05663A4A0FBBF0F438FEBA4FEE03FCCE01699E9630B40C4DE2EE5A67512C03CBA165681B01A40D0B5F67FD2B5E83F0212F50B450100C0B857698BC81F14C084F6E6BBE19EFBBF9E109E1CE605F1BF755C54CDB4190A4064F78B429EB00940C22662DBBD0C104086D374DC3D7EE9BF2C4432840A8CF1BF623516F095C6EC3F7AF04276B91309C0320C4A6BC710F93FE59EC6A1561BF1BF23B953094ABE0640801ADC25731318C08E3D80A7AA33DC3F42F728B15E04F3BFAF30296273220AC06D2554EFBE0B044085D09AE1B01B00401200F9BDC3C0EBBFDED8B322833015C040A44AAF7842EEBFAF4547F1B9AAFC3F0B17F17AC3E112C0D28F505F7D68E6BFDC18906D90111540F453BDDF68B2E4BF5357CAE789250040A070FA33A8BD10C0BE9A5EFB6E0115C0036C13C9EF40034016D7BFB95E64F3BFBC6C8D233E51FEBF0D5BDEAF884108C077C63763BEB5FFBF17F944CB85FB1840DA28F0220F20FDBFCE3D7D3DE58A0940FC9318A91C3001C09D13B5C6BB6C01403F438693D766D23FE9E6072D3BF300C03719C5B29D390B4008C4B9AC2890E43F6FFEC22BEC43E93F192913CEF38BF1BFD8C993E7518502C002A5AAF9218BF83FFC7FE856233E1DC0009489E5DA0AED3F3A6E76C2677611C09C822B1AF953FD3FDB060B44AE23F03F86A67EE081B303403D94F97DE62923C0D634AAC3937DF43F72E7707C7F2BFCBF6A3A36A311640AC0035BCD9A3506F5BF79684CC658D8E3BF22C5322F80A808409EEC4EB3C1B5FEBF5C64BD74BB3212401601E4CB54C80DC0945CC092BD7EEB3FF284A67E4D64FEBF867D8449BD0DF7BF0380C70F8BE701402C4B2019714013C052A0CD1B9D8BF63FAE53DF426EDEB4BFBA024848D2701040D834B5241D2AF43F3678752D0FDE0640EDA202224D0D1740F613C5860E40F1BF14995395C895D6BF8A6426517620D4BF8C78204FD31AFC3F16ED191D27AA0BC09AB6CCC68D0502C0ECAF6BE8D2B4F03F92BD3D45F82313409C3F4E6A8F0900C0984A74B845200840B4109B601DBD11C0C7D4B7DBE555E13FCA0631D3D9471C4003A2345CF32A00C096DA44023BF0C5BFFCD7B828B723ECBF3ED4FAC1B2E5F93F98B2F6097C70ECBFD73F2CAB425FFE3F3092C7CAB1FAB03F46A4B0A696670A408E4BDDF0BA0913C0355E077F53B10340912335DB2E83D0BF1A2E8941C96CFD3FC6B44EC3C4F507C07E2F33697B3FF9BFF259942A90BFD6BF3FA88FF5DAA1EC3F8287977FFB96DEBF605034100F9F01C09A29FDD44388D73FB0E429F5B2C7E73FE911C57CD481E7BF685DE536D2D401C09CA0EBB0E16406401C7041B1E13A0240C4BAD6104C0EFFBF8E02396AE626F73FB6807760BAC2F13F55718BFF3AAFFEBF3F91A11CF05CF13F0AD9A7A0CDEBF23F2A974BF7A835114006D520DF5062E6BFC47C1E1B20780EC0447A758B84EE0D4099E438A098D70040885B22B68FC208C0822E7E359240E7BFBB9962E83B27C13F3ECC45030855FEBFFC65B96A0EFBE7BF02C71163EA88074020A7FD0D17CC19C06ABA1D764876DF3F922629372889E9BFFC0CE005C9EA124042625077F3BFE53F6C6FC1AE910FD7BFF4073CA5FCDF01C0D08C339ABB03DEBFE677556C62FEF93F033BB24443E3FCBFB6E1457B0C56034064D27727EF4E12405231DAEEC557F63F8C513BF1D2920B40C499A8EB3357EABFB635ADC0CEE8F83FBA59A682AA76CA3FCA1B21B9CBF71840B3965739C7F5F7BFBCE285BC737A04C093485B1E31C814C086D18577E3A4F33F10116353A2BFEA3FBD369780368A0EC0D9205BD2DF0D054008B801ADE8DE12C056EE6B4DD4D3FBBF6416932BA1FCF53F36D9426D52DCF3BFD8FA1799B29CFA3F0438D155919100407B7360533D460CC03241B08E9C5709C09AD1B8B1ECB60740C6F2B66E90480B409F52D966458A1CC0CE03CF0D3AF6D4BFECDA28E680DF014072E8FF8877931840464DAF410CEEF2BFB1C5FEF9DA580DC06F4A917D2DBC02C013DC32620BE402C0335F07A4F23A05401096758C2B6309C0E03347E91D1408407AB03E57EA7AFB3F8AF84921B91FD33F1D9461E0EE8B11C0AC4AF66844FEFBBF590F613B519801C0E2A510B18B8CC73F47714C382043DDBFD9B60D8DCE2CF13F6F87305A559E0840E3B59CA3FB7E10C0C0BA5DEB6BBE00C085DD0EBC4203E5BF4FE98021806DE23FF6BC4805953CFDBFC1F8A8A96BEFE9BFCFF0BDA317560740176B24CB5C96F4BFB20D4884049D15C014517CBD60FC09C0350E2434D10A0FC097261286114909400C39955BB843F53F10ED0FF3FA880F40A494FC47BC72EABFB290B735E19C04C0C6DC91C5A9CFE0BF9017AEB416AB16C0DE46F4FD398F14C0FA9FB93B03851040790130B3CCAA06C00C621ADFFFD722C01E3A3D37AAF706C0856D140C88F410400CBA76D3162ED03F44E9A4C247A8D03FD2C55E58A27FD0BFB661ED8588200540BA168EEA0EDEFEBFCCE26A12CEA4F03F3F8229B2B49117403F432A161B4C134031A04027739402C09E1ADA6154240AC0DE43BF50168805C0B4DA6F5F28D8E8BFEC5E21C473C1EE3F5599B2E50AA6E2BFE5E6966B563710C04AD3A7EB22871040A7131EC389FC00C0640C6D74F44BFA3F453EE604CAD1E03F5498A619BCAE1840EC21F8541065EABF1B01502B1407E1BF325559E4565F1CC0ACBB6A88D05D0EC004E97654D590E03F24679E857784EF3F6BD5410EF38100C098A39AEC2CF0FBBFEE2C753D945FDABF11925F4D16881A408D9BC87602A1F0BFBAAF5161DB8400407D4F5EFD05D7F2BF1DEA54078920DABF8FCBB7068F7B02C034E1F625541CFABF581F87C18E3411C07442EA14DE7B0D406E05809B2C9AE1BFE882474A00710FC03C94FEB895B207402ACE554A288F0FC0041A88077AE90340CA6C57ECD32B01C0714E8A41B7BE13408B84B15F568807C0CDEE4E664DD1D2BF40E60609BC9ABCBFA2C334FC2C3BE43F62487498C60207C0E7BAF87C425416409CEC252C12EAD4BF6052C38FE100FB3FB07F67036D5B00401FA639BB703805C05679B72AE61016C0D8E71A4EEC0BF73F7A063DB41C62D63FC8F3F0EEBAE01DC0B3BA61456AE3FB3F053CE4D0E038EDBFEB1FD8E81DE9AA3F16A68D6D74CAFF3FC2DC426B9FBA1840D2E7E2E643EE0CC043406F5E8D4DF33F186B26EBF8ACF73F8815617A43F6F63FDF07AC895345134002433B2BF096F93F28B2889AC8CBE4BFB6E9EC1403E00540A94EF58B47B5FDBFF9771F9A556613C0DA085FBDEA5BF63F1C6FC972FC6FD2BF0690EE3CF45013409F170562558006C07593E6D516E510401F46191163D4F1BF921725800D49E3BFC29F45ACC9E500C09488F12873EF1940B01CEE0B0371CC3FB9CE0CCF85E818C0F428FC12C3F0E4BF40745562ECC50DC07785FD20521413C0E8B79B7B43AEFCBFD1BB3B61EC991540A82623EBA603F1BFA239F2758AF61FC016DC3AB40F4EF2BF4AD83531F5ECEEBF837C1945D497B3BF18779C5DE2A5E63F7FA1A7B1F1940D409060B412AAC1E33FECE432812BC707C06E80D2FBDE910CC04E6D98E70A21E63F6942F82DCDB4E53F11B3A51B7D3E0CC0C26C5583303EE1BFF8E9A6ED51E706C08614B3DCDDCD15C09CB6C899B723194035F7B17427D1F73F10F20A1A4B8EB73FA18A78B54F7F13C0063FEC61573117400E5722A07DA1174036F25A7BD8CE06C0AC39D1E0589B01408A2AD3AF481A09C0144EB0541E1B09C0B92F075C3192C23FEE8034B4B8DE12408587ED0CDA9310C0D504B2A2C70CF4BFF23660BD5C02F9BFB380998C1AC6DFBF272839ED5BA809C0FAA09CCB15341340CBB0DBB3F45002C054F5DCD367E119C038F7F4659064E23F60543D52C869FC3FEB1615C3944704401E390E5BD494FABF5602AF5E37071740685EA2DCB04DD5BFC5FD687C27F1A03F3F6C957DC1C100407E541F7BD95BE7BF4B39E28D3AB90DC0BBC23EFC3F7DF53F4286808FD007F6BF6E257C5D8C9601409CE0BDE523A4F03F7AE47D230A980AC0D81A7E852F230CC00797C680491705C026409447D1EB0440D459FDEFE3C7A5BFBB668ED83658F8BF0B394E19580204409ABFFC0A6E4910409AA426CD648AF3BFDFD4DFA71A3916C0020F008AD6C6154087D844E9ABCA873FC36EEA50BA33F5BFD45B4C336FEA10C016B059AF2719F73F5169F6040334F2BFC4454CAA24360140F3F63ECE91F4F8BF963C9A8FF249BB3F44FAFC4B27830140A4388B81F3410AC0DF6F390CDF3C1440B4ACD3A8718A19C0A20B92B9C5A607C03099137BE85F0C40478E7A7DFCFCF4BFC5B804F25456FFBFE88F726E05010B400853966E5C91EA3F0C99BE2CB8E40840B92CB900BB43E53F8DC30483CA85EFBFBE895DD106B1F1BF4248F5F1FECEFFBF3D2D769C77050B4054F1034EAB430FC07C762F2411E9D83FC0DCF1013D1FDEBF22651830D1300D40E92CF7FC28B30F40C87567253B99F93FEE54F16BFEFEFABF5828D9CF27871140B28D202466C80DC03B9B7426ECE2F43F308E2247F26618C090A0507C6F830B4029AEC60C2EB50240408445C7919610C0762A330B4BF6EB3F8AABB5385C150E408A03CFC45CD4D93F460B3CE269B3E43F8E7FDD827D08D3BF03A7DB644D8B1E4010C116C3FB98E5BF6C2BD367D520F3BFC23B0681810D14C090C410606136FFBF848920F4D76B16C0C4128F01018DE4BF7FB35F69E5F81940E9DEC69E3CEA0A407BFA4C288EE111C0D0E20B0A3646F1BF0EAE1BCF5377084060A8BD71417FE23F4CEE998C0B21B43FB896F5F561BDE83FE580B4900DC8F4BF43D99BB1B07218C03B8694B17542CC3F986E332E1454014024A837D4BA730140D0B96AE014FAF1BFD5E823777E54D4BF8776F95C412500C0FE03EEA32178EBBFA871EAD7B021D7BFDC51F15D37DC0040C059AE51980704405AB26AC1D2370DC06194A6D63A79F03F7C243E6CC296E7BFC6683D0F350FE5BF81697A46A7AB0CC092F5D8FB3871134047F34F2A2CC7FEBF8C857B2F78ACCEBFAB19240869DBE3BFC0ABD3C21FAAF73F18381D202E46F8BFAB81BAA5EF6E17C097670E7390ACDB3FEEB68C40C43BFCBF13C482FE062211C046B179ACE2F70540DFD6A47C0E07FF3F28B938D2BBBA0C40C0AE01C1FAA20D40AD02652F3EEC1240EEA145F252D2FA3F1FB35FAD5DD5EA3F7E5D0D64A287F4BFFDBBC56C9172F93FB63932D5797717C0A8FD1963973E01C07659547A56CC05405E0419DD181E11C096181827915DFEBF43EFB893A164ED3F1CC141FA51ED0CC0883901420710F9BFE1E6CE0602E1114021BA1014282110C0300E05295D31B7BF9456B68CA39406C093BE49F1A1FE0340AE74E18DB34CFD3FDFE6829FF254FBBF5E568FE29A43E4BF386009922581C23FEC65D640B94F03C06BE794A6358AF83F1FB1B5EAEF751140BA8C6A9CA37200C0012E152F7E02CE3FC2936AA576FE0DC0A1535B4744FBF9BF"> : tensor<20x20xcomplex<f64>>
    return %cst : tensor<20x20xcomplex<f64>>
  }
  func.func private @expected() -> (tensor<20x20xcomplex<f64>> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x50EC3FC15839F63F9944C638816E00C0ED326F5F0794FB3F4CC6F2F9EB89FD3FA9C5B3AD20CDEA3F61B275703E4BF73F87D8B3CBB4B3F23F8506A0786643E53F0DDB3A446DF4F33F4CAE2366CC18DFBF963D904197A6F83FFE0CDFB624F0E33F652B6B636EF9044025F875B34AD4F5BF2B018D2E7F7100400E3A3D91EE07E7BF9433DD1DC25D983F5E165FC4748F0040F5E9A7569AC4F93F4E163E5D36FB03C00D206C0BA9F5F33F27D82E41EE230440F762601235EBF33F09E2FC3032C5F5BFD7F1BFDA57A3F63FD80C70495A1700C0990CD2A6EF9ACD3F4D561901C59802C03A373197DF990540143A4DB8C152FC3FBA051AB22549F83FAB29AA766A22FFBFDD87919F6DC5F63FB1C5B8992ED6F83FAF028F12ED61064065B43A7B7B4EF33F6AA7A01EBB6FDE3F46751EAFCAC800405AD1A09EAEC2084048357B04DDF9FA3FEFBE7B1E6810F43F614A51C05717FE3F93B02ED09F11DC3F2237D886A3EFFDBF7E121C531BE8EF3F018D54D508CEEDBFE62819C23380C83FE59FC2DAC2F4F0BFA692B184D54AD73F94B0FDBA6243FD3FAD67CFF88F08C73F5D1CBC2B2C5B01409A2AB18D4941044024AC6A11DDA000C0667A3EBC3041E23FDD0A439DD93004C0FCF32C03A881F23FC971D1A4B561F3BFB2E5A45AB590C93F6443BF6DF865F43F569429660B86F23F584A10420C6EFFBFB202AE1C3430F03F79EB6B3DC34AF33FF71ACFAD7AF3FF3F7ACD569D7938004035817DC20A16FC3F511FF64A1E7A0040CB7B4E475E5EFA3FCFF77CE01795FF3F7D8DD149138B0740410873F82816F3BFE12389A2E9E7014037727EB8DC60D03FC2545B31E863D63F93E9B4CBCCB2FFBF1C907C940200F13F8596E407E40808407E10A55B43F9FC3FA1CE2F4770ECF8BFD8CE50FA7B3AD53FB9B63C25BDF8FFBF6FE7BBA045E3C53F1889C3E57944FABFE5462F4785DF03401BB64486909B0340DDB107E0D3900040E8E187CB911B0340989F41A1A2060340EB03B6841392F73F32D9064A0AEAE03FDD5D7415A389F53F702CBBB04A3AFC3F90FFD3074BB20140A1B0D9572ECEF43FFD078538475701C05097433F3E5506406A5BF05D391BF0BFB5D29BB6F9BAEE3F289D1A2E096EFBBF465615214045D83F0A57E9E86981014025A2AD83F423FA3FCE61F24E9306F63F1DDC0C5C59F9EE3FFAA5DA43C12BFBBFF3D71287ADB5DA3FA35B06F13C1E02C021EFAAA77EF3E63F62411B8AFB1B0140126409F017930240EAD3DABA8A2D06C01C5984E21226D63FD71E1FBD5EA701C012EA4FA2A60FF43F01574BC15516F63F6C25403444ACF03F1E45AD182E5A00C040FB6C981150EE3F104ACCDF700DF93FA53628E196530440271044C4777400C0DB38B874D33B0040C06986BEBF700040F3BBCB983EF3F73F7A4FA8FE1CE7FDBF882958D442BF084047A651E7D35F0440FCC1B888E6D6F13F4F9271068E77EBBF392990CB6D1AE93F6DE05B336B48EF3F85E3DBC3B261F23F3D6501FDA3B403C08FE940F91E440440B0F7B650682D03C09641371C548E074085CB85B21F6301C0E324C834521AF03F9F0DA35C8F8E024009E3EDA6D31CF43FB34C62D8FC01EABFA7B1880409E5CE3F1044D783551D04409BAAD6C4D307E03FC4156F15581AF33F141812F90AC4EF3F4F65EF76E75CF63F76E3B1D22133FA3FF0A2B93BBF70044074F2EC15B3270840E4327EEAF765F4BFE0E637956666FD3F152C061A3F21EC3F6B9E3ED3EDD4E73FC8721B3E15B9F93F2EAA713FDCCADA3F62E4450E3F89FF3FC604378EF1BCF73F9B455FBDBB4C01C0631651FCE9A2C43F26DCEB174D2406404388A4FBE15C02407F3BFD860FFF02401A70D9D72F35D53F0B85789CBF9FFE3F35D0FD17DAEFD43FEC3194D4EACEF73F5982EDEC7CD3FF3FA20A088363BB0140965C4CA9D89FE93FEAA3BEF4C10305C0B1C674CFBB19E53F7823817330F3F63FBBAF6D82B223F73F29F80CCF5F0CFD3F4B5D17EC50ABF73F0FC2D0E246AE024047F15816552EEB3FD899F4B6EF50F93FC9BE316AFBA6FA3F0B73B5F7DF84DB3F5D8EE961EDF90240BA5B848C06FBF9BFF9E5D9367D0BFE3F82A225F9475802C04F3AC8A2144702406B1B823D6D58F7BFB942FDCCA235084052FBE5F0CDCA04402022F8CBC47E02409173D6FD2E2CFBBF1EA3414B3BF0F13FB22880726538F8BFABC818B255F9FE3F27F6F23E7D83004073C48822D20FF93FC14674961929953FA17D279178F407403CDE2103C333FB3FAF6C8C05A251F13FCCDA0A4B5C3AF23F077AC674D27305401BA57F3FF645F7BF2C26D74AB690F83F028F86CA21FBF1BF71B5D3A412750440343B2803D5E20340D818FC4A1ED4E73FAD34C6586D28F13FEF1F97E98CDEF03F82EA95A78F16EA3F2EA90CF97FB70040C6C6D616BBC5F43FAC8B69CA8CF7EA3FE330380BC0EAFABFCE33808D9121E43F95E3AEF8821D0440FCC9E665463801407033D287A006FBBF86231868F892F73F0CDE06401AE903403B3713BEBAE8F03F4A56AC84EBAFFDBF0C794BB7DF60FC3FC95086FD9D2407401E36D7B5A09C004042A901B43B0BD33F9F1A4FF74732E93F4674989B38B30240AF75F4A009780740A0B3D9BBA66AFFBFA11731405307F83F84D37FC9468AF8BFA1856E489CC6E33F3F7F2BDE175FF0BF128BF1E0DE040640A3260DE00584DC3F907CA8E3C297E53F9643CEB1A7C5F93FCDFC6F1F4746024059F80139A45901C06530DD57E3C5FD3FB9D411ECB02CBA3F6B875299345403404C598ACB14060040024252F8F3620140979BF73B928CECBF297ACA3FF22DF83F5EB4C3B04BC0FDBFBA75E7CDCD5B0840BF818170E8E4F43FD1EB5F28E01AFE3F7F65D0F5F650FF3F4F274DAF5156FE3F772BBADA1BB6E2BFF7E6CDB7209403400AC0A029F84000C006BDC515D4EDEA3FA01175B3B5DE06C0CBBE348DC2CEF83F943A84650B11E2BFD8D278689E1B0540A1B9D52AC34D0740D97E8F1CA0E70240946B35BBD8A804C09F704CF41670F23F715F50DCD130F0BF7B13D75A98F0F33F13704CF8D21504C07FB23A515C3DEB3F34A3015156A7F83F8A1E1EFE903BC73FCBA78D83007DFCBF049C2AD9CB090840C4F58A2C2B6A00C0479CE2DF2139F13F056F986048A6F93F6EAC7C42F50D0840C9F3501DDD6701C08CBDDDCBD6A3F13F261D222381EFFABFAAFE737E6D4F01406A5FA9BBFA2F024036332306C8CBFD3FE749DEAB8F0102407C156C21B433C63F0366394DBE46FE3F8E29FB5F7AECFC3F1A95C523702502C0438054619584D43F7E3D6FD2AA18F03FA18AFF05700BE73F339297DDD1EFF2BF5962DBF4E867E13FC1A8AF9D3BEEF7BF532827A7D425EC3FCF9A5DC287B8FD3F46EB655D93B7E73F889830C8568DFCBF03720D51258BE63F9E4985AFC75D034021A62A7B3E80FD3F788EF3D9DBFEF23F675B618212D3F03FDE8A07D21C13F73F75C28B8ED5BDFF3F23740FC06730FE3FCFDF4B7E874908402EE42DEA2DEF0040A7A9BEA444A2F73F9ED8F9C83A29F23F3F6084E1A4A9F03FB3F18C67BBAD03C0BDC7D60CDE43F13F5FA719EAAE25FB3F86F21E928C5206407AF24635557FF3BF961684510012EE3F84562F863C8D0340CBFE87DE37D3BD3FDE55DBAE1BBD04C07FC18499B318FF3FCCF90321611B034040D93D5AFC3E04404097FEA18A07F63F3E281B94C642E93F5B97CEC412B701C0C560340098D9C93F3C51143EE1B300408458A1733BA402400950255E09A9F0BF652A6488384A05403484676E3FF6FEBFF377C14D819EFE3F18B751807230FDBF7AE3A245398A0840A2544ED3FCDE03C0A1E63EB44883FE3FDB5D69250E47FF3FF755E295816DE63FE6D8F311F2B3FDBF54A217109EAFFB3F90FF1A81C20D0340E6A843B2B316004091E5EAE466F5F6BF5D1733F3A1ED07405070AD2856F60140DA99E32BE4D7BF3F138B797EC3D30240925451E1C415F23FFA0260975CE40140259175EA17A605403A2A6486668903C0EF2A061661C80040051E7D8D7D6CF83FF3F12CC2C55B04401A62A7DD6091FF3F5C01D1C74A5BD23F47DFC4807F7C04407D5879C7BA76E33F02F6C81E33470040A0683A5432D4C23FCAE2C7596BD2F6BF8BFE16E274E90040A76A34A7AFB500C077F26F590629F13F055079AB23DBE9BFEA34B422A2C5FF3FFD6AC7662488FA3F198015E61CDAF53F69C0BFC534AA054022D96EA342EEF53FA7648AC27298014071EBD1869AC8E13FF67A0FB90675F6BF9736E9769220F53FDFF1B4A9D9E507408AA3C11C6EA9EF3FCB60EE2C8ED8F73FE8EC630480FC0540E0CB841E9922FF3F63202360CB29FC3F8D5A6EB0FFC7FDBFD066425EC567FF3F81864CD1BB6002C02CD5CA0253410740608FD16DAD2400C052E035038F970340324B24A343D8F83F8E11B6BF7446F23FFCC16964CEF10240BCC6DFCD87E7B43FF2BD8330CB30EC3F2BC3FB9A298BD33FD0542159361F01C0825999D780D7F13F8E635C944A7704C09963776A840F05401FADBEDECE83E53F218BE82D049CFB3F529620280C6FF5BF95919C8E86670440E702572515D7004022E4A3FC4AC3F53F6408FC1E8E5402C05746981B491F014028A754DBA6CDFFBF4E51EBDB9F22084081D9084ECE6B01C09E89A86127FAD13FF60C02089379054019F959EAB530FB3FB09CBBAADE90E93F0331876A8647E23FE57D381EEB59F43FDF18A3652307A53F00D939DB1D1DF4BF68BA8C149F15EF3F0F4CE34C4A9E0340477AA8231A33BD3FC82BD82881E9F83FD0577343489AF03F1158B94B575AFF3F12EE64BAFEEA06405D91749A6A42F13FE1ED6E6D0FF8E73F1C10CEB498EFE43F8AEAEBB44AA807405AC1112C8622F7BF5A9430BC715FEF3FDF326C2C3582E93F19BB0BB5BFCB014037AE607FF990FFBF2F7C3021C777E73F776DD6537094FC3F18D70C68335CE73F9A0E0A70F485F4BFF0610724E2A1044053842C663E58F7BF768B439FBDF0F43F49CBCFA2679801C0A16F2A15C8F2FB3F3B1A83FE917F0040400B9B85A4C7E03FDF17AF37612501C05D17712690310740464B81B8973BFD3F1DE1E3D61B22F83FDE7434082E5DF63F85C344B909EEFC3FF213E4B3C83AFDBF853FB4794984084010AB2DEFB56E04C0D066934E7FC0FB3FF62761BD2F2B02C047A19396A5F3EC3F38A53831AB63DC3F82F528FFC04C07401084EDE88A8EF73FDC2CB2EF5624EC3FD1956AA48D66F93F3156AF88027BF13F9827345870BD02C0EA977A0BDD2AF33FC86E31C4F32700C0E16825481BFCFF3FB61886F5C0E7F4BF7AA02493119CF83FF4226A8F294004C08F0EC6516B9C0040345CE14A34B7FC3F41C54AC57F3E0740D20D3FA5AEE102C04571E658DDC9F53F705DC9B3EF9000407126357A2D1BF13F30E40B716C1303406F5030E4546003409E1A02BD63B2F7BFBC71ECF064460140D597E834AC18F7BF96C3248BF0DAF03FD88CF7E8B8E20040086946053702034024DBFB07C54701C0D029DD454D0CF23F95D9E924C71B0640CB1A988E9F43FB3FED316A9C44D4F8BFA0DFA0ECC2A8C83FFF7D628FB62A044097802FD26F7D04402B7EC8CE7E4401405672AE933A3A02402F6BB4D4E36AFFBF952531B5E4F402408AC91623BE5801C044E4331855B3CA3F6F9DD79D529AF2BFECA59D8F8F080640A6A53C692AE60140E8F210336A620840A882E6C855E1F6BF4B6AA5052311FE3F924DB0EFC8FAEEBFC75B0558ED09EE3F7E31909536AC024092BE0B88CA6D0640C90D87FAF3F4F63FE4E2AA345CC8F43FDA273D326B58F63F37E452572C42FD3FF20947A3082EFDBF2479F45CE5D0FC3F8634DA9CC0510340526C0D65CC1002401E6AD9AC12880240E81C80B3027EDA3FE8B53A3C6B91FEBF421949724948CB3F43FE5B605F930040D9328EDDD6650740D357BE703C01FA3FB2EB67FC99340340A09CF9590CD205403307CBD0F58AE33FCD5FAFC105680240B99705AA47C106405FD31905D4D30740B372AB709461AF3FD141CE664D0001C01E2BEC37A510F53F83956735E3D9D03F500A7EE585EAE43F5392D95469F2FD3F30F674B8D85FF63F594C29B5BDE803C0BF2836B37928DD3FA0D404B3CDEC0240BB4193CCAD82034092239901F311014007E2CF267DE800407B8E51A9FAE3EEBF8F9D6F53495AFB3F1ADC1DC0D9EF0040A1224E73B0FEDE3FC3F9046A76C701402EEC187D53B4D73F86F2D330A5AFF2BFD8E73A6CE63AC13F98F2CB4ACC1F0440F15FE7FDB451FA3F5FA6261D884705408DA57C608E02084006DD66CDDB2700C0B1D9F56D298DF23F2508CC1C7ECFF83F817B64CE83ED064059A029F7F43DF33F9A9F3F137E1DC43FFEAB769469BC044074D0D3E76BE2E13FC3E8C3F4609CF83F864F28CEC7B5FB3FBE46B7CABB61F93F070CAE9504D0FE3FF3ACD5E731D301403C77E9BD96ACC33FC14F7A13D8DAFF3F951A15B4C0E20340161D1F47BC4502C0F22DFEF1B08B0440FA986F3F92D301C0278700199C98FF3FE339E272CE0E03C0529FF4D247490840CE8D3A2B13F7FB3F89BF50B5E7A4FA3FED92110C2628E3BF9628CA13F15400404379DD55FE4504C057E5B32F72C8FB3F5E736FED3AE7F4BFBA7D69EFB3EDED3FF16ACEA6BF87FE3F95A910C50C0F07409E237A57BA6A03C028333B9B0664F83FF8EC18D407AD0540C3240EADF254E13FD15D23B82362F53F9053C5D035C1F83F8B8871A92402F7BFA4E8D04CF112E13F02AA03BCDE4605405AE063AF276AEE3F597268052EC0F5BFDF670F15C395F43F1DEE822B868702C0EC10BD5D7935DD3FB73195F0BAE3F23F19386E9134C9E33FA04F5581CF17FE3F6479407579D806405174AADECF6D02C030DDFBF40011FA3F1860A0747A3D02C0AA1A2D6806320140B473DA86DC9102C01F71B013F2E20340D3EC12387AF0EB3F9699A2111A1FFE3F00BAFC9D11F004C0F14AC250BB91F83F34E1F9787F3B0440EDBE52D097D3FB3F87DB974C284F00403A9B15B57E34064071363DF9968302408CD86CE3DB4BC93F1481AC65982003405991ED9F83FC0740F742F6F017390640F9F2BD53136606404A8B9D5CADFBCC3FDC016A2BCD34F63FF0965645814700C04AB3010D4904F63FA20BF5FB6C3EFD3FAACE89A9018B07400CD0397BF076FFBF746254EA5934F63F7EB3E75D33D8FF3F3155A32271F3FB3FF0D741BD709FFC3F09051F83E8400240C47EC7138A7F06C0FD46EBC00241B53F710016ACE59DEEBFCE6AC195DF1F0240C775F4AA01C005C0D6C298E4F311DD3F603F44A5599004409B89C33DFD31EF3F1F3B17F9BA570040F534CD3E2FBE084038323B3188FCFCBF32213E798D44E73FED35F78DBF3C044068F0F0E29C8201408CF0214FF87FF63FEB0AFBB5807BFB3FB81F193E0E47FE3F898665333BEDDC3FFFE51C36F7DE02403F0B508F586A08403B4CF24C957704C04FCE46A94A79EF3FA024C3125D52FDBF81A61BB2C991FD3F6D28B9DE58EA03C0B0893FC6098FFE3F840172B625F6A1BFE4850C2526C0D73FB3C43695AF30F73F08534051D14506409576FFA4F86F00C03A15372BD3C900407F373C329A9EFABF5A7A09D3BC75F43F6641210B1753FF3F46A88B25F4E2034043171064D65C0140E62BCF187106923F0A2D1759B4DAF93F1548E9C55FBD0040C55910F99880FCBFE194BA8D9E27D33FA00733976A070140984F72A7CCE502408B2C7BD9A5F405C0CAEC94B65105F93FA67B8DFACA7FF13FD570472319700640A1029621277101C0EE030CA8B23200405F625B2AA1B6F9BFAB36149B906C08403DD10DC35D4EF0BFF6A7104DACE8EF3F84636283A0930040D2D4AFFCB2F0EC3FEB9D7D92475506406471D7A09A080240C3EA354261CD01C01D2B952BF0F800400A6BB252541DF93FA563C4BCCB15D03FD8331BB6CCB9FEBF86C13034CC50CC3F79EE3697363DFDBF7E3E1204418C0140EE4E3F0EF0D7F13FF65898180AB6004025984EB8898900C0BD3D229BCD4F08409791E618DC5B00C02F59B5ED301DFB3F9B5C86AB1D1B00C06786DB48C52FD93FE285F60FDC1501C0F8D6702213E5FE3F4E0424F33BFC01C00B89CE5CF35906400B55C6D7876C00C05C1FF253A9FD04406F50110B5A1805C062AD8050EA10F13FB5399DEA3313024080B047DDC597F53FA7D227285F7800C04121F8F74EB4F33F64DA16DF6B84E4BF63814ED613C0F93F91487F9A23D905C0496CE333E1E1FF3F973F4AAA3A5BF13F52B74353C71D0640EB7E84F169F40240567DB326A2340840141358A53F530340FE17A4F3A1D7DE3F13366B5FDB7005C0AFF781D43D310740AA071DA699AA0140753FC430E635C93F24F3FD8033DCFCBFBCBBB7733423F83FFA11C312A2CEE6BF54EC643F2B71FC3F3DCFCA9A17400440F46D653DBBA7F73FB1940AC2774FF8BF324812907861E03F1DB365A3A415F93F16200137F760FB3FF0D27404A65EF73FF93FB46AAC6103408DB4004348C8E03F0B38D396F699EC3FBF67350BB722FEBF0C891859CEDB0640D8430E29001800C0DCB7C59B537601402862D224C28BE73F41A58020D69801408A4EEF6B9BF203C055B8476986FA07405B9AB54AD78AF43F797BA4EAD492FE3F32535896C8B7F3BFE49AAE689622FD3F3F96B5B1C5FE03401AAFF55C21C1F53FC9D64DC0AFA4F53F7D7AB0EB388004409365700C538702C0466F00391268F13F89A6B27706DD00C0E717755C6E38ED3F3E32439F8EE703C011645F38E1E7E03F3FFC327FD983F4BFFDE017E7F88C01409B8D267D5ECCF6BF413D79353E4806403EFABD71BB2A0440449C300E3933F03F9A715CA610920240A1303B9CA622054093FAEC239E7EF6BFF8DC7B4AE5C305401D06753F926D004017D5D9FB46B5E73F461D5C2C8CE6034005688786DF9DF93F7A6B8C22FC2DFC3F58FDFE80E80BE53FFE227604AE12FDBF6F1F725899D205401329572256C5F33F17777922893FF83F91B39E6FEEDBF93FFAC66C7720D7F33F6E353AFC61DF01C0D419D31EDF18084033F2DD1291BBF5BF081DA103D9C50540F562F9ED3DB90040"> : tensor<20x20xcomplex<f64>>
    return %cst : tensor<20x20xcomplex<f64>>
  }
}
