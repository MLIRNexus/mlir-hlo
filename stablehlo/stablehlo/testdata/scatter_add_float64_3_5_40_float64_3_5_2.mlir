// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<3x5x40xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<1> : tensor<2x1xi64>
    %0:2 = call @inputs() : () -> (tensor<3x5x40xf64>, tensor<3x5x2xf64>)
    %1 = call @expected() : () -> tensor<3x5x40xf64>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [2], scatter_dims_to_operand_dims = [2], index_vector_dim = 1>}> ({
    ^bb0(%arg0: tensor<f64>, %arg1: tensor<f64>):
      %3 = stablehlo.add %arg0, %arg1 : tensor<f64>
      stablehlo.return %3 : tensor<f64>
    }) : (tensor<3x5x40xf64>, tensor<2x1xi64>, tensor<3x5x2xf64>) -> tensor<3x5x40xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<3x5x40xf64>, tensor<3x5x40xf64>) -> ()
    return %2 : tensor<3x5x40xf64>
  }
  func.func private @inputs() -> (tensor<3x5x40xf64> {mhlo.layout_mode = "default"}, tensor<3x5x2xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x8AB05978155706C024880DCFCBE4F8BFD691E5C6DDA1D4BF04EC1B8960AF004054E0F89F9656FA3F61E7383193960440C6F1E4F358EC05C0981FC1A0B8FFF2BF9097832A586F09C09F34F674DF3DF63F6C67E02AA9C9CD3F639B67E97E86E73F45A4F953E7F9FD3FC838F863969C074012E85790598E1A40970C409CA755FCBFA856CA2A0B0914C0D09D508E503507C0C204CC7795ABF33FE27305608F7CFEBFE6624EF3564C13C02D38D5CD695414404494601829C8F8BFED8524579B330840D406B9D321A1EF3FD064B297193CE5BFE8483D3E370B1040B6FFC241603BFABF74D1DAD2C4C40240588080C89E040F40FFC4E804C03012409A1602A4722916C04E7D7A539E78F93F10F860CDA50318406E4FC8A77E86104034F62D327F6A02409DE1398073BC1E4053A249D1E6181340363CCE507945F13FB58989787009FEBFC4A754513B62F6BF7F77D0E5DBF700402A3452AB98730BC0E65245F3C63FF3BF9F6354D4E0861340683A84EA3227FCBFFDFB50F0B5F8F4BF40B5245946D9F33F11EAAD864E220DC0296C983D2E6E10C000D5FC217D41B23FE493E51B6BA1F63FB8AD7EB9C36506C01567A62024040C4014B677E50F6A08C060504936B721E1BFBEAA698F9C93C3BF5E62BD2BB0170E40E674C8F805FDFC3F5EB4AF91470E12C091A600545839E3BFFA55F06D9A540740DCAD6D312776E8BFF4374A0310420BC0948C7114DB9EB53FDC6A4AF6EC7BFD3F0EBEB9BA77698EBF91C01870C99CFC3F4E39319C78EAE33F9DEE209A62FD03C0B536764CDDA7E1BF3E08CE85291FB73FC50BBD17D933FA3FCB8A25C6FC5F04C0A007F8703C2F0EC02813D2241C3CEA3FA552C0DF1A7D03C0207952F767120740D0EDA789E839F73F1F15C154D828164008F4B1804341FE3F1D4DFFCCC01F0540DC49B42FB983D53FC9AFFAA9CB4CE23F74B482AEC7EB0EC010C0917E9F071440DEC0B817B737EA3F2200DCF6A95EE5BF2F7453F5DE0A1540C3167402879305404B6FF1EBE7F6164003E742885A24D13F7E3A4C2DC033F8BF324D5C221ADF11C00E233EBB85BFFA3FB6F02A8AACD5D33F604B3B6F74CD11C0BBD6D1F679BFF3BF253B1E846C6FFBBFDE334C71CE7AE23FF8751FBDFD1D014028966AB4EDF30240741DDFFCE508084053D14C2093F0F6BF80659215C76AF23F075BBFCF3D7D15C0C943E0236D71F33F87A6B820B74E0140D66B47BE409EF33F842CA296C4AC0340275E9423B4A1E8BFA9F66FF1E41310402690A460475D004034CEB909F3A7F3BF3F5D0D3787A6DE3F6A182FBC24DFC33F63EC8A12D36EFCBF0C6A596ECBFEF33FD4FE62A00AE70A40334DD4DD865EE1BF7ED136EACF3DE1BF66C1AF842188AB3FAC750CE5DEACFD3F78F3F87CCD0DE7BF04F720E6980412C0D2A966D53A7ECA3F4D3DB98B20CBF5BF5CEF59045D45F83F2485D0342EEC07C0915FAD7DD8E6F23F145378AC670E114000D6879669AAF8BF646B45BAAAE310C0B41825A684A3E0BF3AA68AE0EDF200C08E47CE57E9671BC0E5B18D928D010240401E32CEDEE3F83F79384C8399021FC0FF10C8BD5040FEBF4C46DB08F8301240CA5BD6B19DCC87BFA6DF9DEF41CA0B40E1AF889A3A5BBCBF12D54B40CB71FC3FC86840FA0CDBA33FFD531AACAEBCFCBF000D2BA14A47FBBF0EFDF8289BD4DABF8EDA2FD9D119D13F94582D82B171E73FDD06C9D7CE7801C007A03A7CE648F0BF25DAB9C65EDDB23F2E2723E137630840FEB89BA76DA61AC07580987D0484F3BF3C2FC9984F4CE73F05C7911FD37EE23FA9737BAE048C09C065C7D87D7BE8F8BFC38B4EF0A5B701C0F4A4A44CEC8C08406DD924D5EE0F1140DDB75FFBDABD1940440175F4CDC8F03F1C27740769CC02C099473EAB3E0CFE3F1F4BFA5CC06AF3BFA0FC70FC247CCF3F5CD6F3CE5886F93FF87B51F91BE4E8BFBE3F08B5360E1140BE90F234DFC4C73FC7675351DB6CB53FCDBE28628B02C0BF3816DFA3DCC600409A56DA82709CFEBF6E0102DFBD00E43FF4624553996BF63F05CE511B72BAF33F84311D9DC18F0EC0A4CE70FCA6EC0F401632B82EE42B004029FA6AF6DAA0F7BFC4C09190B91B03400CF52E181C6DEE3F88203CE667B8D93F7B09144E2C71E3BF4D91A08CC47406405E3E98F437E2FEBF38C64EB2CDCDE1BFFC6B14F6497319408EB352B3B9290A40523503AD80D4F33F42E83B02FAEEF2BF64A29EB6244501C03BFC55501045FEBFD11B21F206C8D33F6E601B82CC3113C08F748995D555FE3F4A491B8A51DBFC3FA68B486D3A62C3BF93BA2FB1C58A06402C00F3B39314D8BF8891EF79E9AE0240BED954F6869EFFBFC63987262CA716401F83D19EF47803400C8D49B068C7DCBF84A37360215FE8BF0DA9204AEB4D14C016351A10C044C5BFC6F5D9BD2B69E0BF583A473E51530C40823835A22F13F13F46AF2FCBC69D00C08B9040ADBE5D09C0C0893374BA20CCBF6B69E7CE027601404FB1A36AC822F4BFACD8E20007700BC0964EA945089A03C0084B4D2B14ED04405ABAAF9A726DEE3F5AD4ACF80C241340D569DC4863A1E23F5C5D16AAC92302C0613225BDC87710C09EEA0D2E58090040AE8DA769D72116C0A4B380B711100E4092EF4C011A5204C08EEFBB0D2CE7FC3F2605D926A4A8014024A671B3BFF0D03FAD44047843F310C08073260D1AE4FB3F94B08B2F17130D40A2AD69B7751AF13FFF970E66ADA6A23FE29C306F4D09FABF952FEF8AFAF900C0473063F2E6000E40ADCE1D370A77C5BFB4958C2290FF0540E58A30606BBA1140C003FC130CCB104060EDCE36C283E9BF845B5B8BE2FD054085715394227004C07C7D332AD9B202C0D025FB5F599705C08C826A7119D0E63F6C327898C993EF3F2118B4375E9BBABFC44B999E01230140FB8C68AB132D0D4053A5A183F77CE6BF57BBD6F4D6F0FA3FF6671987F136F4BFAE6B345D574B04C089C5142CAC3A02C05E497BF572901C4080A318A4CCEB0040EC74A94259B80B40CF2254ED872EDC3F2E6D130690460A4074383BB442E2F7BF3512BAFB0435C13F3C057212E31F11C08A7795F0AA870AC065927E0B0BB8F8BF28470D61E265EF3F70509004E186014092AC117FD175E1BFF2A5096F3AEA0AC0606899DB85B1E3BFEAF53879827810C019BB95ACFD68EFBF60D2F86308BE07C05A7ECCA61E6800C0D2C88C5CABF0D4BFCEB2AFAAACDE10409422A1724B2314C0E8620C63475B1B40D1F4149CD19419C0900DF7E11FBFFDBF8472AE58E5D302C0B697974C6A310E40516AD1FBF6D30240E4B83131E022E4BF02B15DF31DF902C0BF547618DC6DFCBFD4BF14282D28F83FE169D7B8D5DEC53FDAA19B0E82A10B40423E93DAF0630940D299F821CD348BBFC4551AA771A908C0CFB9B3D8F6B8054084752D4D235DFE3FC2F1F4E07CD905C00B53AED9B26BE33FF2BFFA1E861A114018338A8147E50C40E813042FB18E0940154E14FE5DB80740F0D31B1C10ED01C03E370A4C4599FC3FDFDD694E56D6174003A6F567494000C04B95D742DC7CC5BFF275E8ECE3530B409184D1D5104117C0165A2BBFD28FF1BFD25C5FB5D47EE63F81784584F00816C042C706E0B87DE73FD62F57FFBE960FC04773B876235F15C0C0554F7F98D507C0CE5505946FE30AC03FE91EA7C86EF23FA5383763340506404A0A7AFC230BF03FB14F261CD08E0340C24A71F6812AF43F5C06CE3B9E6A15C084D46EE780DC18C0CE88CC4A534F0340BB0A580D8875EC3F5A04E5288A3205409C7BF55723C1EF3F7118E418404EE2BF500C3654750608C04C284614532E0CC07110A8C976CED0BFEB2EFAE1411E0C40601F73A4E8AED2BF3F4039976C4DFA3F3A83A0D7B9BC03C0B55CAABDDF1415407AE52F2CA0D517C0B45BF00EFA7917C060B40D233F8FFFBFF82BEB23ABF3ED3FC4E3F1E0C3FA0FC0407461C4A44CEABFF292BC5D9D5C07C064CE97C8BC320EC0E2A8CF25E36606C0C1F1E3CED4C224409B70993F6DA410C0B6890A22867106C0255C85D0A71D1340E7F463811515FD3F2AD14EE22550FE3F30802D120BD511406DDE704CC41416400E36CA2A5F2F1840D9E99BA9A51B0840B0D7A18BADBCFE3F6C9A0D60D2C60D4052E866BD20ECF8BFBFA3B2B80CE90540FEC08183B17F054046A716E0836201C027ADF772669905C01F621BC6A79FFCBFB29F3E20ADCEFC3FE8BD7AB2CC221740BBF1D67FBC900E40DEFF36AE4CF7C13FB0EF1596561E1BC0E72F0B0AC61C1040D040F7653FBC0AC0F50025F100C105C02D1184F8C604EF3FBA1C190A791CE6BF6612A974A0A412409489EFBB929300C00C4FE0D5F18D164028B587B64395EF3F61214CDD64DCC63FD9D8FD40DA890740D15215376CBEF03F38483FB8B1EBF2BF986AE298E57AF83F625A16E83FC507C0601D1D0B8DDCC03FF255155C0DF9144062A8E251DE0F04C0A3070665B59212401CE688DF0D680D403375D0399EE00140F871012610EB1640D2D58966BC6809C06DE8D7989E2F0240C06B31B5BA1503C0A76C11F4014E06C0902B750C128000406980854C3A2501C0C6460CF20BCF09407F821AB33D920840B41B22E23BE00140A77E4624E719C23F277240E4F727E3BF428235AA0C3AD5BF021B07E77A270440C4BD8428C8D7F03FD4AE0CB8D21711C0A3AA9513194205C0F549D45E0BC205C020F823F8B4FEE6BFC77EE858C017F0BF8D07677C2D000B40EAD432827260D53F8857084ADA9700C0C67ACE71AF1D0B40B725EB408C88D73F1CFB8AFC9531F5BF6F0FDBEB815A074068E9726A89A10240B42FCD8C28F2F3BFF4ECA420FDCC05407C564F138593D4BF5A7FA0E823BB1640541222A525EB04C0B9E37885D36CDEBF0F00B2AAD64CECBF9A73083279330D409EE3EFC18350FEBF770D2DD043D3FEBFC4E8C7183611FA3F968559B960C4FC3F6802D63FDE4CF03F302D8D1109C2134027475671FC47E4BFA2299BF319D212C0A22A5AF64ED3F53F02006CDB2C2918C058AECB461838FF3FF32CFFF8B7ACF9BF7622A1C1E83EFABF5555F83E8D52EDBF38CAD2B6FE7D00405A3ADCBBB5100C4014A3AE75715EF7BF9C3C62D2A28DE13F138B24E72E89E63F10DF0BBFC7C4F6BFF64B2A754A4BD2BF0ADEE230CF8002409897DC5517BB0DC07AEE82A417130640661B53318C64FEBF49F21D4BF248C6BFF695F2E9E222FFBF72725F8E25FEFABFEE5F54D6580403C0B801B66062E2FB3F498730F94784E8BF944C4F586F2CF23FCB10C73C3A1D07409CEA8BFDBD0D10C034C49CAF768D15C0341A77BF77CEC23FCD792334DC9ACA3F86179507AFCF134010DB88350B7BCBBFBB29DD3F7C64EDBFBF3FF318AC48D5BF4ED53E1377230FC0D063B5514312FCBF3DC59F6C8BF5F73F9C4208103DEA00C064E5B0B762D3E83F4DF6F3CB031510407E949001B4D1FE3F06AE3DFA9D0E13402F980BFAF4620DC093545913752F09400CBF4320D0F10A407AF6015E763912408C7071D247F3CDBFBA7DB10A79A4F7BFB2E89AAD431318404FC3D65A25940D403FBD149E167CFE3FF8CE3EF46173DE3F015E45099801FFBF1466EF910929DEBF586E0595886F01C0440208AAD2CEE83F765220839211EC3FD39EDD253C68FCBF0581BFDD3E90E93F4E3EFEC137101040A0C692F1B1A4CE3FC63F0C5599FDF13F2F255E199D101240855BE148861510C06E73ECCFCA35FEBF62687C33C3E40840F61BF51DA9DEE53F927D4E60036D07C005C2936E8271F2BF32B023A02C1B0E4006ED4B3CA644EBBFF28719DA5AAD1CC0C377D886FBF601C053ECC934DD92F4BFF6E00CAD4D8CECBFCCCA441C366E10C0BBEE631A1CFA0040A9ED4C092ED2F2BF535C9A120A100A40F06D4141D2EF04401872E423CB2512C0D261728BADC504C0B4A44BBB61B712C0820312A53F3DF53F00FE11624F1916404008DED60AA501C0F7ED6E1D64C70340CB77D1DF57ACF43F381A3F7120A9FFBF527F9E8215100FC02D1E48553B66D4BFA2085835BFA3CF3F1C446FAB8249FFBFAE985D5946D1FDBFB0F68286A4E20DC07A6A04EA3913BD3F923FC1D670CBFFBF94CBEB08EC721EC025BBD422D458E9BF58EC628E7360D3BF9EE5B4F10C53FDBF42159C8D894FD23FE8F876C1D6241EC056B7B9D8C43815C0A6851CB202BE13C03BE08E96088F06C0D77D1DB435F700C0A57C390FC0BCE83FC50DABF82E4703C07826878F590C0240568362713C6F14C0042BED90147117405030A8DC9CC412C02247597473D9EABFD67F45E44AAD0FC03CFB26C6EF2FF93F02D6524171F2F83FD53C0ED2AD9AE2BF8C003459D1E91B4015D3FFF9B03F124073C46178DE13104084C7406715EFFB3FBCE05D09DB0E10404E54E3D8B11DEC3FB836CEB577F073BF99547A897A0F0BC0C9CC69C20A880D404B7D1CEB94EEE5BF98AA91A07AC8BFBFB7D04AB72A43D2BFE675186C541EE43F13F8C4DAC07F1040F5EFE2562FB8F13FC0DB036ED85A9EBFF6C5873AFEC8F2BF804C9C595DCADC3F4C99CD853A63CD3F27769D9D5C1C15C0F7714CE1BC6305407464F616AB6606C03C394B03D8610F407622E870D59FF9BFEB7A270F498410C093DA2676FE90F13FCE47988E1FA40540584D5C0F119DD83FF6EC4B2E541DCCBFC4F1085DF8FCE1BF0BCE9D269E54B8BFE2951B2284F6D2BF62A7F409B200124096D3EBE9B76AC6BF532C76DE757608403814CFD38D96FEBF9C2D0E2FBC1A0AC01C73339273D215404BBF62C77A5201400F8684DD64E3E13F9B0D9591258D07C0D1C9E229311117C0D3F8E143A3B9E43F"> : tensor<3x5x40xf64>
    %cst_0 = stablehlo.constant dense<[[[-0.27822111534894056, 1.5589846520684871], [-6.4082680221936235, -2.8364575092594571], [2.7398412070985243, -1.6308487989438771], [-3.1407732224401284, -1.2163422501631422], [-5.2631318482912288, 1.1269339084648144]], [[-1.1513937511597758, 0.54189835082669657], [-1.4179091699849167, -0.37713087496730424], [1.8297593095678812, 0.10036536701591639], [2.3647764933545345, -2.9118763827255538], [1.908639385742082, 3.3094513961296714]], [[3.9330919577671288, -1.0227778713624369], [-3.8752267774967706, 2.1186875730490033], [-5.148933535146246, 0.84192537160703829], [2.1581938309691249, -0.29445198308403991], [-5.6128513089450784, -3.3278221384686191]]]> : tensor<3x5x2xf64>
    return %cst, %cst_0 : tensor<3x5x40xf64>, tensor<3x5x2xf64>
  }
  func.func private @expected() -> (tensor<3x5x40xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x8AB05978155706C09C762E9C279BD1BFD691E5C6DDA1D4BF04EC1B8960AF004054E0F89F9656FA3F61E7383193960440C6F1E4F358EC05C0981FC1A0B8FFF2BF9097832A586F09C09F34F674DF3DF63F6C67E02AA9C9CD3F639B67E97E86E73F45A4F953E7F9FD3FC838F863969C074012E85790598E1A40970C409CA755FCBFA856CA2A0B0914C0D09D508E503507C0C204CC7795ABF33FE27305608F7CFEBFE6624EF3564C13C02D38D5CD695414404494601829C8F8BFED8524579B330840D406B9D321A1EF3FD064B297193CE5BFE8483D3E370B1040B6FFC241603BFABF74D1DAD2C4C40240588080C89E040F40FFC4E804C03012409A1602A4722916C04E7D7A539E78F93F10F860CDA50318406E4FC8A77E86104034F62D327F6A02409DE1398073BC1E4053A249D1E6181340363CCE507945F13FB58989787009FEBFC4A754513B62F6BF8C1D8061AB7E1CC02A3452AB98730BC0E65245F3C63FF3BF9F6354D4E0861340683A84EA3227FCBFFDFB50F0B5F8F4BF40B5245946D9F33F11EAAD864E220DC0296C983D2E6E10C000D5FC217D41B23FE493E51B6BA1F63FB8AD7EB9C36506C01567A62024040C4014B677E50F6A08C060504936B721E1BFBEAA698F9C93C3BF5E62BD2BB0170E40E674C8F805FDFC3F5EB4AF91470E12C091A600545839E3BFFA55F06D9A540740DCAD6D312776E8BFF4374A0310420BC0948C7114DB9EB53FDC6A4AF6EC7BFD3F0EBEB9BA77698EBF91C01870C99CFC3F4E39319C78EAE33F9DEE209A62FD03C0B536764CDDA7E1BF3E08CE85291FB73FC50BBD17D933FA3FCB8A25C6FC5F04C0A007F8703C2F0EC02813D2241C3CEA3FA552C0DF1A7D03C0207952F767120740D0EDA789E839F73F1F15C154D828164008F4B1804341FE3FDB976336F8FE0D40DC49B42FB983D53FC9AFFAA9CB4CE23F74B482AEC7EB0EC010C0917E9F071440DEC0B817B737EA3F2200DCF6A95EE5BF2F7453F5DE0A1540C3167402879305404B6FF1EBE7F6164003E742885A24D13F7E3A4C2DC033F8BF324D5C221ADF11C00E233EBB85BFFA3FB6F02A8AACD5D33F604B3B6F74CD11C0BBD6D1F679BFF3BF253B1E846C6FFBBFDE334C71CE7AE23FF8751FBDFD1D014028966AB4EDF30240741DDFFCE508084053D14C2093F0F6BF80659215C76AF23F075BBFCF3D7D15C0C943E0236D71F33F87A6B820B74E0140D66B47BE409EF33F842CA296C4AC0340275E9423B4A1E8BFA9F66FF1E41310402690A460475D004034CEB909F3A7F3BF3F5D0D3787A6DE3F6A182FBC24DFC33F63EC8A12D36EFCBF0C6A596ECBFEF33FD4FE62A00AE70A40334DD4DD865EE1BF7ED136EACF3DE1BF8F88A56A9F3611C0AC750CE5DEACFD3F78F3F87CCD0DE7BF04F720E6980412C0D2A966D53A7ECA3F4D3DB98B20CBF5BF5CEF59045D45F83F2485D0342EEC07C0915FAD7DD8E6F23F145378AC670E114000D6879669AAF8BF646B45BAAAE310C0B41825A684A3E0BF3AA68AE0EDF200C08E47CE57E9671BC0E5B18D928D010240401E32CEDEE3F83F79384C8399021FC0FF10C8BD5040FEBF4C46DB08F8301240CA5BD6B19DCC87BFA6DF9DEF41CA0B40E1AF889A3A5BBCBF12D54B40CB71FC3FC86840FA0CDBA33FFD531AACAEBCFCBF000D2BA14A47FBBF0EFDF8289BD4DABF8EDA2FD9D119D13F94582D82B171E73FDD06C9D7CE7801C007A03A7CE648F0BF25DAB9C65EDDB23F2E2723E137630840FEB89BA76DA61AC07580987D0484F3BF3C2FC9984F4CE73F05C7911FD37EE23FA9737BAE048C09C065C7D87D7BE8F8BFFF9E2C714A6719C0F4A4A44CEC8C08406DD924D5EE0F1140DDB75FFBDABD1940440175F4CDC8F03F1C27740769CC02C099473EAB3E0CFE3F1F4BFA5CC06AF3BFA0FC70FC247CCF3F5CD6F3CE5886F93FF87B51F91BE4E8BFBE3F08B5360E1140BE90F234DFC4C73FC7675351DB6CB53FCDBE28628B02C0BF3816DFA3DCC600409A56DA82709CFEBF6E0102DFBD00E43FF4624553996BF63F05CE511B72BAF33F84311D9DC18F0EC0A4CE70FCA6EC0F401632B82EE42B004029FA6AF6DAA0F7BFC4C09190B91B03400CF52E181C6DEE3F88203CE667B8D93F7B09144E2C71E3BF4D91A08CC47406405E3E98F437E2FEBF38C64EB2CDCDE1BFFC6B14F6497319408EB352B3B9290A40523503AD80D4F33F42E83B02FAEEF2BF64A29EB6244501C03BFC55501045FEBFD11B21F206C8D33F6E601B82CC3113C08F748995D555FE3FF365634AD31AF33FA68B486D3A62C3BF93BA2FB1C58A06402C00F3B39314D8BF8891EF79E9AE0240BED954F6869EFFBFC63987262CA716401F83D19EF47803400C8D49B068C7DCBF84A37360215FE8BF0DA9204AEB4D14C016351A10C044C5BFC6F5D9BD2B69E0BF583A473E51530C40823835A22F13F13F46AF2FCBC69D00C08B9040ADBE5D09C0C0893374BA20CCBF6B69E7CE027601404FB1A36AC822F4BFACD8E20007700BC0964EA945089A03C0084B4D2B14ED04405ABAAF9A726DEE3F5AD4ACF80C241340D569DC4863A1E23F5C5D16AAC92302C0613225BDC87710C09EEA0D2E58090040AE8DA769D72116C0A4B380B711100E4092EF4C011A5204C08EEFBB0D2CE7FC3F2605D926A4A8014024A671B3BFF0D03FAD44047843F310C08073260D1AE4FB3F94B08B2F17130D40A2AD69B7751AF13FFF970E66ADA6A23F9BF218ACE4600BC0952FEF8AFAF900C0473063F2E6000E40ADCE1D370A77C5BFB4958C2290FF0540E58A30606BBA1140C003FC130CCB104060EDCE36C283E9BF845B5B8BE2FD054085715394227004C07C7D332AD9B202C0D025FB5F599705C08C826A7119D0E63F6C327898C993EF3F2118B4375E9BBABFC44B999E01230140FB8C68AB132D0D4053A5A183F77CE6BF57BBD6F4D6F0FA3FF6671987F136F4BFAE6B345D574B04C089C5142CAC3A02C05E497BF572901C4080A318A4CCEB0040EC74A94259B80B40CF2254ED872EDC3F2E6D130690460A4074383BB442E2F7BF3512BAFB0435C13F3C057212E31F11C08A7795F0AA870AC065927E0B0BB8F8BF28470D61E265EF3F70509004E186014092AC117FD175E1BFF2A5096F3AEA0AC0606899DB85B1E3BFEAF53879827810C019BB95ACFD68EFBF60D2F86308BE07C05E846E3E2EE7BEBFD2C88C5CABF0D4BFCEB2AFAAACDE10409422A1724B2314C0E8620C63475B1B40D1F4149CD19419C0900DF7E11FBFFDBF8472AE58E5D302C0B697974C6A310E40516AD1FBF6D30240E4B83131E022E4BF02B15DF31DF902C0BF547618DC6DFCBFD4BF14282D28F83FE169D7B8D5DEC53FDAA19B0E82A10B40423E93DAF0630940D299F821CD348BBFC4551AA771A908C0CFB9B3D8F6B8054084752D4D235DFE3FC2F1F4E07CD905C00B53AED9B26BE33FF2BFFA1E861A114018338A8147E50C40E813042FB18E0940154E14FE5DB80740F0D31B1C10ED01C03E370A4C4599FC3FDFDD694E56D6174003A6F567494000C04B95D742DC7CC5BFF275E8ECE3530B409184D1D5104117C0165A2BBFD28FF1BFD25C5FB5D47EE63F81784584F00816C042C706E0B87DE73FD62F57FFBE960FC04773B876235F15C0F14873670E360CC0CE5505946FE30AC03FE91EA7C86EF23FA5383763340506404A0A7AFC230BF03FB14F261CD08E0340C24A71F6812AF43F5C06CE3B9E6A15C084D46EE780DC18C0CE88CC4A534F0340BB0A580D8875EC3F5A04E5288A3205409C7BF55723C1EF3F7118E418404EE2BF500C3654750608C04C284614532E0CC07110A8C976CED0BFEB2EFAE1411E0C40601F73A4E8AED2BF3F4039976C4DFA3F3A83A0D7B9BC03C0B55CAABDDF1415407AE52F2CA0D517C0B45BF00EFA7917C060B40D233F8FFFBFF82BEB23ABF3ED3FC4E3F1E0C3FA0FC0407461C4A44CEABFF292BC5D9D5C07C064CE97C8BC320EC0E2A8CF25E36606C0C1F1E3CED4C224409B70993F6DA410C0B6890A22867106C0255C85D0A71D1340E7F463811515FD3F2AD14EE22550FE3F30802D120BD511406DDE704CC41416400E36CA2A5F2F1840F85FB60293762040B0D7A18BADBCFE3F6C9A0D60D2C60D4052E866BD20ECF8BFBFA3B2B80CE90540FEC08183B17F054046A716E0836201C027ADF772669905C01F621BC6A79FFCBFB29F3E20ADCEFC3FE8BD7AB2CC221740BBF1D67FBC900E40DEFF36AE4CF7C13FB0EF1596561E1BC0E72F0B0AC61C1040D040F7653FBC0AC0F50025F100C105C02D1184F8C604EF3FBA1C190A791CE6BF6612A974A0A412409489EFBB929300C00C4FE0D5F18D164028B587B64395EF3F61214CDD64DCC63FD9D8FD40DA890740D15215376CBEF03F38483FB8B1EBF2BF986AE298E57AF83F625A16E83FC507C0601D1D0B8DDCC03FF255155C0DF9144062A8E251DE0F04C0A3070665B59212401CE688DF0D680D403375D0399EE00140F871012610EB1640D2D58966BC6809C06DE8D7989E2F0240C06B31B5BA1503C0A76C11F4014E06C0C35E736632E413406980854C3A2501C0C6460CF20BCF09407F821AB33D920840B41B22E23BE00140A77E4624E719C23F277240E4F727E3BF428235AA0C3AD5BF021B07E77A270440C4BD8428C8D7F03FD4AE0CB8D21711C0A3AA9513194205C0F549D45E0BC205C020F823F8B4FEE6BFC77EE858C017F0BF8D07677C2D000B40EAD432827260D53F8857084ADA9700C0C67ACE71AF1D0B40B725EB408C88D73F1CFB8AFC9531F5BF6F0FDBEB815A074068E9726A89A10240B42FCD8C28F2F3BFF4ECA420FDCC05407C564F138593D4BF5A7FA0E823BB1640541222A525EB04C0B9E37885D36CDEBF0F00B2AAD64CECBF9A73083279330D409EE3EFC18350FEBF770D2DD043D3FEBFC4E8C7183611FA3F968559B960C4FC3F6802D63FDE4CF03F302D8D1109C2134027475671FC47E4BFA2299BF319D212C0A22A5AF64ED3F53FE8FA0012DF2F1FC058AECB461838FF3FF32CFFF8B7ACF9BF7622A1C1E83EFABF5555F83E8D52EDBF38CAD2B6FE7D00405A3ADCBBB5100C4014A3AE75715EF7BF9C3C62D2A28DE13F138B24E72E89E63F10DF0BBFC7C4F6BFF64B2A754A4BD2BF0ADEE230CF8002409897DC5517BB0DC07AEE82A417130640661B53318C64FEBF49F21D4BF248C6BFF695F2E9E222FFBF72725F8E25FEFABFEE5F54D6580403C0B801B66062E2FB3F498730F94784E8BF944C4F586F2CF23FCB10C73C3A1D07409CEA8BFDBD0D10C034C49CAF768D15C0341A77BF77CEC23FCD792334DC9ACA3F86179507AFCF134010DB88350B7BCBBFBB29DD3F7C64EDBFBF3FF318AC48D5BF4ED53E1377230FC0D063B5514312FCBF3DC59F6C8BF5F73F9C4208103DEA00C064E5B0B762D3E83F4DF6F3CB031510407E949001B4D1FE3F06AE3DFA9D0E134026D21DD6DAEB1FC093545913752F09400CBF4320D0F10A407AF6015E763912408C7071D247F3CDBFBA7DB10A79A4F7BFB2E89AAD431318404FC3D65A25940D403FBD149E167CFE3FF8CE3EF46173DE3F015E45099801FFBF1466EF910929DEBF586E0595886F01C0440208AAD2CEE83F765220839211EC3FD39EDD253C68FCBF0581BFDD3E90E93F4E3EFEC137101040A0C692F1B1A4CE3FC63F0C5599FDF13F2F255E199D101240855BE148861510C06E73ECCFCA35FEBF62687C33C3E40840F61BF51DA9DEE53F927D4E60036D07C005C2936E8271F2BF32B023A02C1B0E4006ED4B3CA644EBBFF28719DA5AAD1CC0C377D886FBF601C053ECC934DD92F4BFF6E00CAD4D8CECBFCCCA441C366E10C0BBEE631A1CFA0040A9ED4C092ED2F2BF535C9A120A100A40F06D4141D2EF04401872E423CB2512C0D261728BADC504C05E7630FAD18506C0820312A53F3DF53F00FE11624F1916404008DED60AA501C0F7ED6E1D64C70340CB77D1DF57ACF43F381A3F7120A9FFBF527F9E8215100FC02D1E48553B66D4BFA2085835BFA3CF3F1C446FAB8249FFBFAE985D5946D1FDBFB0F68286A4E20DC07A6A04EA3913BD3F923FC1D670CBFFBF94CBEB08EC721EC025BBD422D458E9BF58EC628E7360D3BF9EE5B4F10C53FDBF42159C8D894FD23FE8F876C1D6241EC056B7B9D8C43815C0A6851CB202BE13C03BE08E96088F06C0D77D1DB435F700C0A57C390FC0BCE83FC50DABF82E4703C07826878F590C0240568362713C6F14C0042BED90147117405030A8DC9CC412C02247597473D9EABFD67F45E44AAD0FC03CFB26C6EF2FF93F02D6524171F2F83FD53C0ED2AD9AE2BF8C003459D1E91B4015D3FFF9B03F124073C46178DE13104084C7406715EFFB3F408D15DD64B413C04E54E3D8B11DEC3FB836CEB577F073BF99547A897A0F0BC0C9CC69C20A880D404B7D1CEB94EEE5BF98AA91A07AC8BFBFB7D04AB72A43D2BFE675186C541EE43F13F8C4DAC07F1040F5EFE2562FB8F13FC0DB036ED85A9EBFF6C5873AFEC8F2BF804C9C595DCADC3F4C99CD853A63CD3F27769D9D5C1C15C0F7714CE1BC6305407464F616AB6606C03C394B03D8610F407622E870D59FF9BFEB7A270F498410C093DA2676FE90F13FCE47988E1FA40540584D5C0F119DD83FF6EC4B2E541DCCBFC4F1085DF8FCE1BF0BCE9D269E54B8BFE2951B2284F6D2BF62A7F409B200124096D3EBE9B76AC6BF532C76DE757608403814CFD38D96FEBF9C2D0E2FBC1A0AC01C73339273D215404BBF62C77A5201400F8684DD64E3E13F9B0D9591258D07C0D1C9E229311117C0D3F8E143A3B9E43F"> : tensor<3x5x40xf64>
    return %cst : tensor<3x5x40xf64>
  }
}
