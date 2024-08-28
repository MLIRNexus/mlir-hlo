// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0:2 = call @inputs() : () -> (tensor<20x20xf64>, tensor<20x20xf64>)
    %1 = call @expected() : () -> tensor<20x20xf64>
    %2 = stablehlo.maximum %0#0, %0#1 : tensor<20x20xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<20x20xf64>, tensor<20x20xf64>) -> ()
    return %2 : tensor<20x20xf64>
  }
  func.func private @inputs() -> (tensor<20x20xf64> {mhlo.layout_mode = "default"}, tensor<20x20xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xA56317818DF9F1BF9241C8C4AAC2FBBF8F23A4C640B9E7BF6EFAFFC27B2FBB3F3CD4238CEAC0014063C18133C49ECDBFAF847FCA41D90BC0DCA9457B15CF0A4078D8F194AA9802C0F5FAB2495F6A13C09DD1A75E59C9F3BF7CE1DA49EFFD134039A4BFC3BC0B96BF20A9A773E154FE3FD6CB2047B7C5044088598F56E3F70640F933861AEAABF0BF89BE6E44B344FCBFE624284FDA5EE03F922381DDB0610DC0FF29740B7D55F3BFF185EEB849E9A23F8E2180C0E8A0EA3FA4559780CCD9D83F9063F7B59EF9DABF8A8410DE547C0CC0AF82072E39D106C02EB521D5FA9FEABF1F26324D99D619C0DC6347D56EB520C02F92C80FF97BD2BF358A5601DDBDF63FAF8620A7719CF23FA46FD19DC31A04C02A7C2BB546B8FF3FAE6AED01D126244098F7FFFCA856F5BF561717FEFA72C4BF7361E078CA250EC013553AF2F4510740B56E01FA5C9E07C03299A915192DFC3F2448F5FDC3141640C0DE06AB920A00C0D6E93AEAC2421040708E68DCB58FF2BF5B74018F0DDB01C0CE6779646ED4B23FD3CE4BB421E90440726793BD9E4C0B40AFAEB842BDD1DA3F2C3AB5FB2C290240406C87B2B7841140480CD3E3AD8E0940C21F4EADB39E0CC0C6F4342D49081F40B6F323841D330040E360FF545B3E014066002CE5FB2214C0C45149AAFCF618C0FAF267D603E312408606D6A8C0E6B9BFCAF80AF2626A12C098093DB0146C05C02A808CEAC65860BFB959AE2FF077F9BF5E8570F087E2FC3F98DC741E684B0340C0A65F690E6E08C08D8B9AA5E217E03F3BC231827B8B14C0BBA34FE1530FE7BF24F337B8082AD6BF6AB50F9D9656C7BF4798C104CEDC0140E5A3536C1D1B11C03854DAF8AEE8CEBF8A9722029CDC0FC05EEF7DA58028F43F9631C2D4D1630F40795975972A7C0640A0C556E5FD4DF13FE41538DFCF7EF43F1E96EF4F4F9D1FC0B14F58CA9E5AF93FA52D2951001B04C05BA2D1967EA211C01AF811EEFA73D63F3AB82F68CEE1D13FC298E2DD791AF03F57B32B4C5E2017C046AEA2905257F5BF9E22429022A3FDBF324627A456670F409241B72EA00B17C02C89DD23A807F5BF584D0032D00AC3BFA07AF8D556C816C0280E7CEA0B22FE3F6367925F818C10C02DD6E513442E12C0D8861CA3D1E6F5BF11212D51B3C0F73F60A67CDC01CA1740C01D33CBD2A8F3BF625855731E06FEBF3992836BA16EFA3F8CEC60103D1314C0A00B63B2009BF3BF00471BC88C5E15405EDCCAA099D5F23F1CF96111EEA6FDBF923DDE3954DD10C046F0889F4BE400C0584C057C6E8111C03846CD104259F63F5CB51D9BF16FFF3F75DE878FC42A0EC05F05C5E53088F43F0FD2A31BD5D0F63FA735B9596B84044018A3A148C52FFB3F6AC80CBB59DDB53F08AE3938C50E16C0AE52F4812D10D53F9CE336B975D5EA3FA83EDCEF1DF71640F622C977207311C0E04C5A420552E0BF0D5038605C85F2BF2E988383805BF23FDA8F0F86C5690CC07A3AA789A9BC10C08B8DE197DE5AF9BFB24F1E22454F06C0DFD2486B8E7009C0225BFE406842E1BFD74EEFC017A8C1BF0238680405D5F4BFE0F541102FAD0E403898BC65DF34A23F779475793033D1BFA68D842759EDFABF7CD3F679F27212C04C5DDF5500220340E301FDC101ECF33FD76C1C7C41E6EC3FD287DBD7AD28F7BF0AF4E4A9530A06C0F3A08037914EF63FAD66E0AF3B980E4039B664A5A5BA0B40068D1B5F1F80FA3FAFE25139226F14C024AD3C3B072A0D4076FEBA617E2DD9BFE6131B632948F93FB4B6CED7D605034078C6775DD6B8F23FCD2192281701F7BF1EF61C31AA9B01C0A0D231DAA07AF6BF6B081270F33CFF3F7AA018CC9F2DEEBFE2C76DE6F45206402F6ED2A17CCCEABF2E110EA8627FC1BF81B86CF12076F2BF5E52C28B59251440642D22BA01D408C0114BA03DBC51054024535078DC9602C0306969D960E90C4064D9E30CF882D5BFE6BB36A105180FC070580BF287C9D73F76887299B89100C07F3D13EFA59502C0EEC47C89F116FBBF64C0A8BA616EDE3FF4372BBB5392FA3F0743F68948BB05C09F08A47A35BD06403AC46F9B83D4FABF2F4D90E87192074010A36E89F2DCF03FF96BEE0F68D6D63F391B829BCFBA04C0E4035B4556B009C0C11D5156C0EF0AC05569A1A1E62509C006425AA0D0A4F43FBF379A23101906C01F95E98D257701C06C1E40CFBF661C40EFEFA4A0F1270CC0C0C12D3BC5BF0440A72D9320BC82D13F60DD16F344A703C032F882248E5C1640FD55ACCA3E120BC09C19E1294CBF08C0E9969F0AF88CBDBFBA5D43220086D6BF0CE03D5DAF3D0440BC101F9A6A21F03FDE5BD0FF6EB1D93F3AABC4DB03E1E2BFCBCB16D7AB5BE9BFC87308CC1493F3BF7D13F7797F5BDABF7B243D54616F0040D51871056E751340B70D536ED7F80540E8FE31915DF7FEBFE86E6D799099F73F5EE2185FD6C3B2BFD9A5C3D3077DF7BF087398718FCBF2BF26E688E72C6FCFBF0242E1B8EC1613C05CF38EE6B648D2BFC8A1D5AECBE80840DDD4AC2BD9900A40E87BE8492B7E1340FE8A54D5A680FC3FAE0D6A18C4320AC00814327B4F780F40B8ABEA565242FF3F58408D898AAE1E40C3BC29816D0F06C00883E33CDE34DFBFF2E1C258FE97E23F26FAAEBB25960AC01AB3830ACF4901400BBA129BF4AFF83F56A3D7753379FBBFC498C321E3DFF8BF0E1CD54D563EE4BF2861D8DCB31A0D40F6E621AE05E0014058E5B8D78B70FDBF7E6F06476CBADE3F74FC946B35CBF5BFFAC3454B1ED0E2BFD2611E917A990D40410089251BAEF53F061F67091C50E23F41B69D49A96F03407BB9E45576E504C0CA80F1070B3118C05AD917C4071707C03EDBEFB7EC140C407ACD375C3B6AFFBFB3988FBF40D80BC0C14C61C5CF950440AC37E31E60AC21C0746FEC50FF04D43F82A6E330373400404FB532F8250FD33F329E6CA9BD15E23F59507CCBE23E1040921715C2EED00C40217BF0F0F66AF0BF528FE15CDD25E4BF5B3805CAE2F50B40E8C13A3E829C08C0AB9B4C5BB704B63FD1DC7C18939CF23FA43213195D941340D9D45B3DA19F01403FD02EA1BD6709C0088C147FD028E23F02F1A25312961DC034B4A4877A100CC0E43CCC34054BD2BFBE053E8B5B35F43F68821F15C315D6BF4CC40A1CBA5BDABF2C37B92CD7C6F73F5998951A69F3DF3FAE72DC5C2EBB00407F073705F2C803402812028721310DC0DD78A57A7C370B40C40AF4D6D0D2EDBF0CF456598EE80A40826474FD0D23F33F4B52008253A408402A3878A108FDE73FB42BA4437BBCBABF2ED463790BAAFABF882732024D7615406872D8AA4C57FA3FF0960620BD4413C010CE5927AE2B00C05A207F17693A1A4074C5988FFB4B07C03334B291EA940540741EF12F653D084022DF07B2965BF5BF18C35D36A48F02C006ED773F6F3C0C40C337C7E2CAC4ECBF491E432683A0E5BF9DF258E4E58E10C02258A086F345D83FAE3A6B7FA0DEFA3FE0F57714A5F60EC0030D69118B3E01406F6328D03D390340324A19EA874D0B40325FD9AF7EA3D93F05E66551BEA9E9BFEFBBF1D6DE6FEFBF21D5D3FF6BED0740D9A36E1C318DF2BF25139BC9C03E0EC0591AFA393CC202C060DB472438A6014018A2AC661FB0F5BF12A0412C8471F0BFE864FCED520D10405AE81CF66673D73FED0E9B1C4AEC03C09CF3665BBD8B0B40F0D7FEE637CFFBBFA75D12888C02F53FC3A06A28E788FD3FA5F82522317EF0BFA8EFCA29C937DFBF3293F536EB981240EE6EED4FE6B202402A1E2C0B53960DC06842D19F5D54EDBF7AEF93A33D95E0BF92885575861BA03FDCBC33769DBE0B40853666423BFC13C0F28D13768BE4034045CA8D0582F41040AA27BC71345D08C09459307E1844EBBF56174FFB1B4EE43F4F2E44B7ED29E7BF6ED5EB72109A14C0A0FD16A7257AD1BF83A15CC984710440CE159C1FDA69FD3F18657669D6FC04C062FFF83998900BC078AFFBB8D8E21AC019FD8E79B8E4D63F5D44FC9F2F07B1BF234D9EAFDB072040601145885D13FB3F309E942D98F0FABFAC876BE3E00AEABF27040AD3B62409C04C824901C21BEEBF03BA349DE280EFBFAACE9013CFBF0CC0FC5F1EC532E7FBBF9F600C0280190240355296715F11D3BF341468A2D9D307C0AAB2DFDDF2A6E1BF1C2870F85ABC15C046D9C0554D7608C0B4ACD13B116FF7BF867BE3333CB200C05BCA59A2F6680640F477EE1C46BD0A408861A4BBCF5813C068A852B23F7B0240CE530F1089A610C04012F534923FF33F1EB1AB9FC71218C0E23BFB04E0361140DC84C53F971C0D401B98D8EC2B49AEBFEE171FC26D050840447013B3581C1E4072CBF0671066E2BF47FF08BEE4B50440C6E29812BAC8C83F199F07E0173C02407EED1E480BC0164097F16C6C370E0C4076EF33211AF212405289A14BCD2A06C09456805CB010C3BF0C6589E9F116F33FA88616EE278F9ABF4AEB30C83A75FE3FDCA6CB42E493E5BFC5B80D9569D304C0EA1AA12026B1D7BFF7D94AEDAE17F0BFD80C20E4FB4EFCBF"> : tensor<20x20xf64>
    %cst_0 = stablehlo.constant dense<"0x422C1E79E076EA3F940F5AE5A4A410C01E4B080F646C144048423EA7C2B4F13FE2B8ED0565DFD3BF1A173509633115C065C5FF664EAF16C0284EC6BCD36E0940568E86A353EC1340477431E6856BE6BF0A56D3D83AD601C0A1B9B418F8C8FF3F29FDC541864104C04D5A9727EDF504C0063A7980B42E12C06157A0B7726203C0788EACE9BFCE05405B31BAF0EE7ED53F94D6F20FD157F6BF9E4088356C9D12C086D8B0916F1EBABFAE537D63ACEE01C0C21B56F8A42910407F040CE8EB3605C062E8232BF61D0240582C83DF425C0840A842F8DDCEF5FE3F867B8F39D11ADB3F343DA993BE9DE2BF45B772E9ED9304C09EB95095AD17114090A04A9AE696D3BF1D83261DA01403C0D49907277120F23F0E97D4EA4404F23FBAE03A65594506C0A2F48CE6704C1040808FE0B87D24044022B40D7D8C9D0A40223DC1B9F518F2BF4BC41998519DE93F94AB68E5951FEB3F7CA91A863A20F6BF7453B3608739144089D5C27C8622F9BF3BCFE1EA6BFCF43F5DCE80CF2BE409407CC0CD6CEA2E00C0DABD08294C77F63FDBA9CB6CBAEE84BF56DBBBFCCA9BEF3F8DED8250E5D5F23F2E9C17A8655DCBBFA42C9D3E7F09C13F384FF0154595BBBF604988ABEFEDF0BFB495E2C6AE12174075BD85857013134082E514D55E2E0C408D5BDF3295AFD33F790BFBE13EC7BC3F7C5C94187BD2CBBFF0AE4682CFE4F73F8099457CE08012C0C86E013E9925F2BF9B39EB8644EE0CC0F51F6A5FD4C1F83FD60A3BA443C6104097DD09498CE5F43F409420AB45D50540C49ED962292EF63F7824264011FA02402329C6B2A33CC7BFE0BEFB65E588F2BF0814B6FDFA7FDABFF9B29CE5B758F6BF98811C4A568201C0167653776CE0F93F92AA3AA24015F73FC6D7A7663C8415C044717127D4F30CC01329353F21A8F4BFC474B5ADD0B60BC0CFD9DED05AD809C0E24393510534E2BF14EB18796A8C0D400C6376D39F3DEA3FF6571852461CFA3F294D5F3D308A1040B354CE8370E3FBBFD10D97A91A7D1BC06440B7545122FEBF52F48E3F508B0440EB832EA884BCF83FBC4F353817A6D9BF8A9DF4A336490A409CC33198899410C056EE9514A3510DC0D118A723788AF43FDEBFA64B54250A400481D932719C05C0ACAA92A40437F1BF894E387CC29C0240031815E0A21EF43FE0CF26462E130BC0443726DB6F010140A279BC22CA360EC0DD9A9E0E31B90DC0EA94C3B466EA09C03557B22F41B21140CC06BAAAAE1EF1BFCA5AFC31F181D6BF6908DF7E834E12C04A7863D43835FD3F4F449EFB2AFAEF3F404FD086F153B1BF68A16BBB25EA03C088055402AE780A407D72E8FE93260AC06690ED2CF16CD93FFC6F7D9699FC0DC0B6F52B1B55D80CC056F8DCDB3117ECBFA46280AE27E7C0BF3CC7DEC8DF7A0AC0771FCE6454C519C00D6FF88EB9240EC0BCF0CAC27705BBBF65FAF8CB4BFD0440C4AD77A347A01340B857505BED2209C0741A113D3D70F0BFA94B821F0221E2BFE01917E0E385F2BF0A78783614A0EFBF2A845FAB808AFE3FBFA440C270D5E93F434FF757B2DCF03F142F2210C1C9CCBF850FD2F54251C33F25CAFDDAA35CD93F127BE6A03DA107C0B72BC1854FAB10C05341225D500DF53F41C466068A3E10C01BAE41E87096BDBFA469BE01FDF60D40B348B6D72EA706C072C644679449A53FEEAF48F0A7A70CC07104976A2A1202C0BAC23535F589DE3F58F5FD93D9A208C080963C700535004065B50FF80F9F15407E09E0EC005A05C0925497883EBDBCBF0F9E51091680FCBFB5473FD1790410C07D51CE735F541140CBE15323987510C0561C76F6422F09C018F6A18AB9CDF13FD6F0609498E20AC0085FD0CB56E70AC0284276BB2B68A2BF1C85F3E2550E17C0E54FB435E61FA0BF2E2A66F98C4213C0C3484633C7AA10406A36C0E261B9E5BF5F25065889BDFB3F15D823A73439024020DC71D4822D074012E01FCDB885E93F2CB6FA8CD9C6F93FBE30E5CD6D3701C05C3363F4CCFDE0BF20C0C7C5164C17C0CA3BC3014E62FB3F4BCF495F1A3707C01F7575DC072610C0CC84630A995312402B81B8E7EFFDF3BF5AEB0C9F5B5D05C0D78286528515F2BF5CF9DA6B41B7B73F6766773057591FC0943F6C228F6B02C04A7C1E044E13F4BFC4A9D7145ABFE1BF8ACE8C759DC7EABF5872C5A16157FBBFB837553ECB3E144096AA30004819DFBF82BD13F89E1BE2BF749C6D74603A01C05933440F2BE0E5BFD69EAA283E43D8BF63AD237B1F47DDBF3C079FBF5CC30D404A71C563A5A2E23F045B5B0345E4054008CE82E97D371B409DC1082B7353034080C11811D24DD9BF8028B440276BF13F2801740291A902408DC157F7B0C912407EE0879EA7AE0FC0CF705F2D0E17F6BF1658E5C5647CF8BF042EBB3AEE890FC0A4406C7FF0F919408C7561892537EDBFE0449ED1DE8F16C033AEBA06D9AC16C0404217214C58F1BF3CD9A7C3EF83ECBFA5EB5166235FF2BFA17C6336D73BFDBF82E3B020AD0AE63F928B17F8C5A0EFBF0C0CE797835F0F40E8E077D4EA3C0040D6F03796A7610840EAB277580E790040A2B37F4473290640741B06E4523D13C0586846BC988115C0E1BC93A9C522F53F8CC87A8C267C08C0D07EBEEFF3F0FE3F3191555B1F8E14C0883C2A26827C024026F1D5913C190FC0AB07A7913D26FABFB2B658716CAB0A409F23E343C0A301404E4A8C0CED84CCBFEC698F906CD1E93F0AEED60F1E81F4BF785278710E220B406040BBBBE646E13F93E96027B299EBBFD417882CA0F80240F4B5847ECE51E23FDAE02D02F26110C08B991211FCB51540A8B24735B0F3FC3F6B82CAA15E720AC0B2F6695183040BC0ADE1964DAC5401407433025F957FF5BFBBC58F9AF80D00407B6E41100A8A1440491C2231789B12C0BEE33220446E07C0EA8415F27462F23F3C734CC009DCC9BFCA753C4CDAC101406C25AACA14E70DC0485C73F2AA100A4082263BDFBBDA03C0B908E00462B120C0500191452ACB0A40AAA856729CC307400E7455A71879FE3F1A7DAE1298D1A73F8125F355BF071340F3D95D4EB40E0440768F239BA23F10C0D3B7487303990CC00C4B8E324E2803C0C4D5F6D9E44FE93F866124FFF6CEF53F849485C32B97FFBFC9128E197244E43FB4F3D0E54EBAF23F14A34CE6A0F2E03F6BCC1EA04CDA0540B72B2AA07F87E0BF3AE2C8C87E39F33F09A8E1A0438407C0DEBA9CD266020DC07A85FDCBDE40054086EA7F6C7DAB05C0DE6B8B0A9BCAFCBF4294716906F21240B440FF1AFBD70940723957986B86F83FBC8154A0F9FA00C084F79B14E9AFF2BF084453ADBF4902405ACFF60CA6A0F23F1A85921D69A6F1BF011D6770422CF5BF02334B51E92704404E13DC93512616402BA0F5C6BE8EE4BFE26B49CA7901F5BF3D6EBE5B102B03407ABF59CEE0DDD8BF662B74ABEF02A6BF8B2D287EF922F83FFFE6524873730340A216184D4B1BFEBF4AF5A53765E313C0C67FF0D6541D963F20FD4881D7B7C93FD3908430F1B6D7BF4446C4408A7CE83FD1B5A3091ABDDEBFA7D228B55527FCBFDD609FFF93AC11409C6D17C6962A1440B396801F54AF0640A6FCC85612C909C0D06A8ED39887AABFAA6C415CF857C93FAD122BC0DED303C083A0B3A001CA19C00BD5858599C0CA3F5C2B24796F10E8BF9D1D0B29D9ABF6BFC8C5613CAB97FF3F3AE91B24783AD0BF009F035F83B01840145381B22BEBF33F6569DC21DEAD15C04C55D08F73BA13C0709F51E4344AD0BF62EA2C294FF2ACBFD32BF8EAF881D8BF72317298F18B0EC0684D098CEAF8F23F10CBCCB552A20A40C5F38373CC0FD4BFC6E26A36F4DA0C40FA1315AE0F711240B0FE403F2562F8BF9CB67102C2B90940E154D3DF3E92084030A9109A2A0AFC3F68541DF8F13D02C031AC452B42F4F6BF2ABD3521020EFA3FAE60871CB36D1540BA2169CA1069F53FC14D3873003B01C05EF77C6B2634EC3F9E0458F13059FD3F1606AD8B5FED0EC0BA03E321C7CCE0BFFEDD8620466C07C0FB9E12992B1AEA3F92B56D5C0FE1E9BF17696B453AEEF1BFBD9E390BF66807C0D8F10F0BFA6511C01A5EEF2D1FDA144072AE758B053E03C0B473D323CF73D0BF6063325C6710F1BFE6F30D26A77813408DEF775F7986F5BFAA5EE27B9BEDF7BF81D0625113F2FB3F558DF1C6B81DF4BF31E46EC86E4C0C407D04AEE38EC11340FC76E1FF2FEA17C0BF33C40A1C991240B5005C1E8858F33F4D5906461299C63F92F464AFC54E024016B14C04BCFAC9BFDB38FA0FDAC4F1BF9CD132085D2D1740AC4947F9BFFCE9BF707DB6E22BD41AC05243E8636AC305408EE308CC2CABFE3FA5BB4447DBBE04C0BD74B6F58764ED3F08BD1E4E02E9D7BF3256B7EE0ABBF63FFF858A5A6DB41040CC140EF6F04505405888649DC6C104C05A3C2863E50609406C7717B79C3DEDBFF5837AD04F1702C0E7D2EF5834F0EABF920323D3A45B14C0988DA9A4B6E40FC023C47EEEAA52D53F6D9E27C1575D13C08A02EED4E57010C014A6C42BE9871840"> : tensor<20x20xf64>
    return %cst, %cst_0 : tensor<20x20xf64>, tensor<20x20xf64>
  }
  func.func private @expected() -> (tensor<20x20xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x422C1E79E076EA3F9241C8C4AAC2FBBF1E4B080F646C144048423EA7C2B4F13F3CD4238CEAC0014063C18133C49ECDBFAF847FCA41D90BC0DCA9457B15CF0A40568E86A353EC1340477431E6856BE6BF9DD1A75E59C9F3BF7CE1DA49EFFD134039A4BFC3BC0B96BF20A9A773E154FE3FD6CB2047B7C5044088598F56E3F70640788EACE9BFCE05405B31BAF0EE7ED53FE624284FDA5EE03F922381DDB0610DC086D8B0916F1EBABFF185EEB849E9A23FC21B56F8A4291040A4559780CCD9D83F62E8232BF61D0240582C83DF425C0840A842F8DDCEF5FE3F867B8F39D11ADB3F343DA993BE9DE2BF45B772E9ED9304C09EB95095AD171140358A5601DDBDF63FAF8620A7719CF23FD49907277120F23F2A7C2BB546B8FF3FAE6AED01D1262440A2F48CE6704C1040808FE0B87D24044022B40D7D8C9D0A4013553AF2F45107404BC41998519DE93F3299A915192DFC3F2448F5FDC31416407453B36087391440D6E93AEAC24210403BCFE1EA6BFCF43F5DCE80CF2BE40940CE6779646ED4B23FD3CE4BB421E90440726793BD9E4C0B4056DBBBFCCA9BEF3F2C3AB5FB2C290240406C87B2B7841140480CD3E3AD8E0940384FF0154595BBBFC6F4342D49081F40B495E2C6AE12174075BD85857013134082E514D55E2E0C408D5BDF3295AFD33FFAF267D603E312408606D6A8C0E6B9BFF0AE4682CFE4F73F98093DB0146C05C02A808CEAC65860BFB959AE2FF077F9BF5E8570F087E2FC3FD60A3BA443C6104097DD09498CE5F43F409420AB45D50540C49ED962292EF63F7824264011FA02402329C6B2A33CC7BF6AB50F9D9656C7BF4798C104CEDC0140F9B29CE5B758F6BF3854DAF8AEE8CEBF167653776CE0F93F92AA3AA24015F73F9631C2D4D1630F40795975972A7C0640A0C556E5FD4DF13FE41538DFCF7EF43FCFD9DED05AD809C0B14F58CA9E5AF93F14EB18796A8C0D400C6376D39F3DEA3FF6571852461CFA3F294D5F3D308A1040C298E2DD791AF03F57B32B4C5E2017C046AEA2905257F5BF52F48E3F508B0440324627A456670F40BC4F353817A6D9BF8A9DF4A336490A40584D0032D00AC3BF56EE9514A3510DC0280E7CEA0B22FE3FDEBFA64B54250A400481D932719C05C0ACAA92A40437F1BF894E387CC29C024060A67CDC01CA1740C01D33CBD2A8F3BF443726DB6F0101403992836BA16EFA3FDD9A9E0E31B90DC0A00B63B2009BF3BF00471BC88C5E15405EDCCAA099D5F23FCA5AFC31F181D6BF923DDE3954DD10C04A7863D43835FD3F4F449EFB2AFAEF3F3846CD104259F63F5CB51D9BF16FFF3F88055402AE780A405F05C5E53088F43F0FD2A31BD5D0F63FA735B9596B84044018A3A148C52FFB3F6AC80CBB59DDB53FA46280AE27E7C0BFAE52F4812D10D53F9CE336B975D5EA3FA83EDCEF1DF71640BCF0CAC27705BBBF65FAF8CB4BFD0440C4AD77A347A013402E988383805BF23F741A113D3D70F0BFA94B821F0221E2BFE01917E0E385F2BF0A78783614A0EFBF2A845FAB808AFE3FBFA440C270D5E93F434FF757B2DCF03F142F2210C1C9CCBFE0F541102FAD0E4025CAFDDAA35CD93F779475793033D1BFA68D842759EDFABF5341225D500DF53F4C5DDF5500220340E301FDC101ECF33FA469BE01FDF60D40D287DBD7AD28F7BF72C644679449A53FF3A08037914EF63FAD66E0AF3B980E4039B664A5A5BA0B40068D1B5F1F80FA3F80963C700535004065B50FF80F9F154076FEBA617E2DD9BFE6131B632948F93FB4B6CED7D605034078C6775DD6B8F23F7D51CE735F5411401EF61C31AA9B01C0A0D231DAA07AF6BF6B081270F33CFF3F7AA018CC9F2DEEBFE2C76DE6F4520640284276BB2B68A2BF2E110EA8627FC1BFE54FB435E61FA0BF5E52C28B59251440C3484633C7AA1040114BA03DBC5105405F25065889BDFB3F306969D960E90C4020DC71D4822D074012E01FCDB885E93F2CB6FA8CD9C6F93F76887299B89100C05C3363F4CCFDE0BFEEC47C89F116FBBFCA3BC3014E62FB3FF4372BBB5392FA3F0743F68948BB05C0CC84630A995312402B81B8E7EFFDF3BF2F4D90E87192074010A36E89F2DCF03FF96BEE0F68D6D63F391B829BCFBA04C0943F6C228F6B02C04A7C1E044E13F4BFC4A9D7145ABFE1BF06425AA0D0A4F43F5872C5A16157FBBFB837553ECB3E14406C1E40CFBF661C4082BD13F89E1BE2BFC0C12D3BC5BF0440A72D9320BC82D13FD69EAA283E43D8BF32F882248E5C16403C079FBF5CC30D404A71C563A5A2E23F045B5B0345E4054008CE82E97D371B400CE03D5DAF3D0440BC101F9A6A21F03F8028B440276BF13F2801740291A902408DC157F7B0C91240C87308CC1493F3BF7D13F7797F5BDABF7B243D54616F0040D51871056E751340A4406C7FF0F919408C7561892537EDBFE86E6D799099F73F5EE2185FD6C3B2BF404217214C58F1BF3CD9A7C3EF83ECBF26E688E72C6FCFBFA17C6336D73BFDBF82E3B020AD0AE63FC8A1D5AECBE808400C0CE797835F0F40E87BE8492B7E1340D6F03796A7610840EAB277580E7900400814327B4F780F40B8ABEA565242FF3F58408D898AAE1E40E1BC93A9C522F53F0883E33CDE34DFBFD07EBEEFF3F0FE3F26FAAEBB25960AC0883C2A26827C02400BBA129BF4AFF83FAB07A7913D26FABFB2B658716CAB0A409F23E343C0A301402861D8DCB31A0D40F6E621AE05E001400AEED60F1E81F4BF785278710E220B406040BBBBE646E13FFAC3454B1ED0E2BFD2611E917A990D40410089251BAEF53F061F67091C50E23F8B991211FCB51540A8B24735B0F3FC3F6B82CAA15E720AC05AD917C4071707C03EDBEFB7EC140C407433025F957FF5BFBBC58F9AF80D00407B6E41100A8A1440491C2231789B12C0746FEC50FF04D43F82A6E330373400404FB532F8250FD33FCA753C4CDAC1014059507CCBE23E1040921715C2EED00C40217BF0F0F66AF0BF528FE15CDD25E4BF5B3805CAE2F50B40AAA856729CC307400E7455A71879FE3FD1DC7C18939CF23FA43213195D941340F3D95D4EB40E04403FD02EA1BD6709C0088C147FD028E23F0C4B8E324E2803C0C4D5F6D9E44FE93F866124FFF6CEF53FBE053E8B5B35F43FC9128E197244E43FB4F3D0E54EBAF23F2C37B92CD7C6F73F6BCC1EA04CDA0540AE72DC5C2EBB00407F073705F2C8034009A8E1A0438407C0DD78A57A7C370B407A85FDCBDE4005400CF456598EE80A40826474FD0D23F33F4294716906F21240B440FF1AFBD70940723957986B86F83F2ED463790BAAFABF882732024D761540084453ADBF4902405ACFF60CA6A0F23F1A85921D69A6F1BF5A207F17693A1A4002334B51E92704404E13DC9351261640741EF12F653D0840E26B49CA7901F5BF3D6EBE5B102B034006ED773F6F3C0C40662B74ABEF02A6BF8B2D287EF922F83FFFE65248737303402258A086F345D83FAE3A6B7FA0DEFA3FC67FF0D6541D963F030D69118B3E01406F6328D03D390340324A19EA874D0B40325FD9AF7EA3D93F05E66551BEA9E9BFDD609FFF93AC11409C6D17C6962A1440B396801F54AF0640A6FCC85612C909C0D06A8ED39887AABF60DB472438A6014018A2AC661FB0F5BF12A0412C8471F0BFE864FCED520D10405AE81CF66673D73F9D1D0B29D9ABF6BF9CF3665BBD8B0B403AE91B24783AD0BF009F035F83B01840C3A06A28E788FD3FA5F82522317EF0BFA8EFCA29C937DFBF3293F536EB981240EE6EED4FE6B20240D32BF8EAF881D8BF6842D19F5D54EDBF684D098CEAF8F23F10CBCCB552A20A40DCBC33769DBE0B40C6E26A36F4DA0C40FA1315AE0F71124045CA8D0582F410409CB67102C2B90940E154D3DF3E92084030A9109A2A0AFC3F4F2E44B7ED29E7BF31AC452B42F4F6BF2ABD3521020EFA3FAE60871CB36D1540CE159C1FDA69FD3FC14D3873003B01C05EF77C6B2634EC3F9E0458F13059FD3F19FD8E79B8E4D63F5D44FC9F2F07B1BF234D9EAFDB072040601145885D13FB3F92B56D5C0FE1E9BFAC876BE3E00AEABFBD9E390BF66807C04C824901C21BEEBF1A5EEF2D1FDA144072AE758B053E03C0B473D323CF73D0BF9F600C0280190240E6F30D26A77813408DEF775F7986F5BFAAB2DFDDF2A6E1BF81D0625113F2FB3F558DF1C6B81DF4BF31E46EC86E4C0C407D04AEE38EC113405BCA59A2F6680640BF33C40A1C991240B5005C1E8858F33F68A852B23F7B024092F464AFC54E02404012F534923FF33FDB38FA0FDAC4F1BF9CD132085D2D1740DC84C53F971C0D401B98D8EC2B49AEBFEE171FC26D050840447013B3581C1E4072CBF0671066E2BF47FF08BEE4B50440C6E29812BAC8C83F199F07E0173C02407EED1E480BC0164097F16C6C370E0C4076EF33211AF212405A3C2863E50609409456805CB010C3BF0C6589E9F116F33FA88616EE278F9ABF4AEB30C83A75FE3FDCA6CB42E493E5BF23C47EEEAA52D53FEA1AA12026B1D7BFF7D94AEDAE17F0BF14A6C42BE9871840"> : tensor<20x20xf64>
    return %cst : tensor<20x20xf64>
  }
}
