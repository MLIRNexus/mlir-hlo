// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<20x20xf64> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %0 = call @inputs() : () -> tensor<20x20xf64>
    %1 = call @expected() : () -> tensor<20x20xf64>
    %2 = stablehlo.exponential_minus_one %0 : tensor<20x20xf64>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<20x20xf64>, tensor<20x20xf64>) -> ()
    return %2 : tensor<20x20xf64>
  }
  func.func private @inputs() -> (tensor<20x20xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x6413798505ADFFBF744D5C13BBEEDCBF46D3106D5202D7BF917EAD5C8A39F23FDFF0846AFD3600C0B5436DC444B910C0D067A70E5384D1BF9AE181C39F2614C04C4605D5C0930CC04CC15230947AE73F076FC0F790AFF73F2ABAFBC2062E08C0D21B003BCC36F53FEC7A746CB4C1E93F469D1A44B71620C05238102E68A7A03F19976370BF79EB3F80C754985ABA05C044F05FA1D64209C0BEF23C93A033CC3F6279BD54FA3306C07147B3EDF570C23F58E81C8ACB2019C0628ACA3E4A8E12C06047FEB4E0A51AC01C2178B42B8EF83F5AD833D5F807F13F649048E6760F11C0705F06C929F7D5BFFED4F258774613C05D448564420910C02BF5946F6F0CC03F3CA91AD7074005408C2518A0E83706C0655CFA73F69DFDBFDAB739A52CE004C06E822DB528DF00C02095C7BE5192FABFA4D1A5C6304617C0C22840A7D77003C06EA4222A264D0340680EC61D671610C02BAB3BC8853DE1BF0A56BB53B9B72140095AB84EBC241340D0C16502C5E1EFBF9ED8A4D6F22BF93F4BE2E5D8D783F43F61FF621236CED4BFD620A44AF7E9FC3F5072F95CF5DC054071333E0347381740E23FF0616F710CC012C3465AB0B20EC0CE2BA02672B60AC0E6EF54C1949911C02864B1F2253713C08098A7984F47EEBF729102BA01F2CEBFA189872064970040154A8644358DFF3FE95C1BBD053FF6BF767C876F0BA6FC3F7DA0698180F212C0AAE9F1354CE8E43F8D0C43085CAF03C0AA08159A83B611C0F9FB2327DBC2F53FB1D4CB0D154FE83FA4866D7E080200404D006285CB2B1640CE9E6574C0BEF5BF801DBE6C3ABFF1BF9492FC1A3F35E2BF5662A75A422DF1BF11DE380DDB2E0EC05E3C22BCEEDA1B4014DCD5A4E87FEFBFA63D95878B24FABF7ACE95362B9A04C0D32DB666F89505C0A0988CF36B0BEC3F283EE08DC19500C0DA037D65FB36EEBF347B28E30BC50B4074948C7B3BE0FA3FE6FF289F3C2BF9BFC504EC67BBBBF2BF5D909316E94D1C40C3C619F9E935DCBFC39BF75E51120440DEA35B608BD4F6BFB03FC49E5143F3BF58785B5E5801E5BFD8B63855A380AE3FBCE2DDABEA3F0440002263FA36D60FC05EDF80BCD3C715404B3DD4BB69B5D03F4800B0BBD1D9E83FFAF06D9EEF170B404E99DD4074E9F03F57E2EB8E590AE1BF2F95C957F5B906C0FE3F2CC5095C12C02C05178CAB8302C0C885741FD09D08405C8FC72894AEF6BF36D4DFCFD355F7BF38F21A97624BE5BF812BEA487F97FEBF2E07DAFD138EF7BF9410F1A4686EFCBFD582326078D50EC01B2CF6D3F6C0F4BF2A5EEA352B2F10C041F842838164F33F2A3893E03333ED3FFDADBD26A7B1FABFDCDC60E24CDE00C0AAB26E6B6CD810C03E13A8DFCAA1EABF1C0B0227E93D124015B78AE499F20F40B24DB4F0FA4715C0EB1E1E600BB3D3BF388859F65969E23F1015C7E3193F024072CD3DFEF131EDBFCA5D95ACCEF3F33FA3EE7F14AF5101408820A298901EFFBF7AF357A8F066B3BF2908C593BE45F4BFF07C927C28EEF93F0266C1374682F1BFF6732F2B7E69C53FEE00716D58AD07401C2BC5F4126BF5BF54255636A045DD3F36E02F5E402F1740E107088CD86EDDBFA2C7D5638E71F0BFAEDB788AA61412C0FACABD13DC0BDF3FA68A95412D25F4BFC85DFD16BDB0E43F21CDCDA86837F6BF24AB17BC8A0E0040CA9935BBA899134096D7745BA0B3EFBF390E8C62BEB2ECBF40E9CBF8E1C61040B9EE47663D90E53FB2618AE33E7CFF3FAE55FA25DB229B3FC99B1FC87DB9FE3F5E5AEAFF638900C076BE8402DE1CEE3F0CA74806B97C044095FEFC4F032E11C0BBDD7D4DBE8F1440FAC223DECEFA1A4037B6AFC520BC9D3F2EB8F297D6EBDABF20FC10571E27DF3F42533FE4CEA9A83FB4E28A382A80FBBFE95BF3372FCBECBF5A921F4CE237F93F042ABEF64E0A13403168E9F22B54FC3FF08D5913F6DD0AC03F5D54305BBBE1BF6687770427D6B5BFD4168889A13B01C0DF694093BCAF03C005B0F25E04DBCCBFB74E2AFB311D10C056D586F4CF3DF13F36C11AB6068312404EC600DFEC8709C01E3AFCC70202EF3F500D7797F175F0BFCEF7588AAE49E1BFF4BB5F18C7AA0C40B7B4B12A4B1109C006E7754B9A4A13C07C9526EADDA611C0E525F4C7B68BF73F8B863746C5011FC05AA183DC7081FE3F20E30233594706C0E5F5FC0D9B3717C015CF13114530EBBF509C871FCB78FEBF51914871803D0740EFA180B08A31FBBF85C6100B29280040AE762A9EADD6E63FBFE09055FAC3E5BFFFE9AF35BAE2E2BFCF3B92188A25A93F77019BCB86A7ECBFC7EB0DBB61BC11C0342AC6530E05F8BF0D4ADFD0D250014028F560D5FEE40FC0A258A08DC79F0840DC52BF05D257F93F3114F094876604401AC6436C738F02C0065F528EE884104032AD6DD798BF0340E44158AFA934FE3FFDE0F5094B10DBBFB6463F8567F710C00F3D301D1028FC3F98446924DB5801C0AD2972FC98DE1240DF5EA047170911C000081648978FEABFBC1716C83FBDECBF0A355D96FF71FE3FAD26D38DE839FB3F3CCBBB9B30410B400E8213D842D7F03F92B46F37AEDE0A40CADE7D0A23ADFD3FE0ACF3C8FB6BF23F5A0A68B75089044034694F4076C405C04DFC20FEA44B16C0868EE9A281ED14C0B4C03C4056E607C0C9FC587256DBF8BFA80946F27A9C1AC02D4BE74C6E910A402C2D2E92FFDD0B406BFC51E5588213C060918651DF0CFF3F0C61EFD0A6D4F13F5E3479644A1B0DC094B407E86299DABF7FA881A00B98DEBFC25E24A3D0CF10C08277347B05A1F03F20DAABF72844D13F2D3D1F69190810C04CC74A621292FBBF32C42DEE70010C403E35002063DA15C0D5F5ACBFB33AF4BF5D3027F96623F3BFD2DF6A373733FE3F90FE8962BA370A4043F6AD1F98FF07C0D91C5F625F5EF23FB1AA1DB55C24FD3F28106FEFD024F13FD7A05CA5D1D609C0D7BE27B5864BEEBF20C3DE59FAD1F73F1411A981414FE7BFEC37651E6FAC02C0A46A2F5435AC05C033548A0E798B1540901C5FB4ECB00CC08144CF15E0DBD0BF7A03ECF60AD1E03F3E266BC45CBDF7BF93515EA3C8471340234238D55EFEC63FBBCA91592A11EABFCAAE55A6C3A812C0E66817FAF42DBA3F3B0286E3828910C07A8C6150BBABE7BFAA6186EB2F3D0BC0AC70D51A072513400FA4C77E55EB0FC01A5DD30D7F0D01C0B92C08C8252011C0385048109D2D04C0565CB6661B6704C0AC80EAE4387418401A6E21B3AD1802C0CC4EA1D5B220D1BF43F1A1CEF293ECBFAE3E2541208100400C5ED8950258F13F71F8D500ADC5AFBF72754FB9C00F0BC0ADC6F025E5AD01C08E2CD9F0EF9B05C0506FA86DF7A1D83F9F9F8B9E86AFF83FA9218481EDAD084002656EB4D7090CC07E59F9FA2DCD903F3BF6D102C6068BBF82A8898AF0F4FEBFCEABC7E919F301C0DA38530A0EC1C8BFFB778A0E6FB60240022F61D3BDDD0340600C5764F27EEA3F9874F010182B2040B72EC66F95B81640DA9C43ECC4700B407C8558A9A855F53FBC5DC7A5A8A8F6BF40BCAFEEB7DF07401C1F87A4E118F53F962CC9676C1F01C036015C076D7819C0E602F5780E540340E188F905766A07C02C570B9F40EF10C0E6A6E3FC5B43F3BF087AF838743F0F409EC56A8CF8FAFE3FBF376905A2DAF13FE999853C6855F03F122E3874B924EA3F08CF6333552C0940D2B306A09A96E33FA4BD6DB2EFCBEEBFE12887D8D5D306C04506644DD16EF3BF4287B8D86BCB0AC0760735F5B4E804C0CF2898B4820712C043EB6E5E0201FF3FFC09705A95641840F93815D110A9A83F32C2D198E12DE73FB49C825A20450140556A7359F18B004035D6C82FF1660340A26EFB20C16DF63F2287B43CB0BCFD3F665F8792FCA004C0580E5F576A4BE43FA3B302C406BB0640BEA3CFFEA595A9BFD070D775121AEDBF2DBB7E82C61F17C0382CA830C4DA0CC022BC6FCEDCA81640762A50AD54F01A40D295A582D0880B40D8B1D29B910BFABF1CAF232E82BBD0BF307D93B0070DFDBFC462E8A9614CF4BF29872F0F9A4EF9BFD6ECB2B5A07FDCBFC4578A81741C0040AAD0153CD1BC0840F2461E9469E9EE3FC61647BAC5240EC04DCA5908BFD0F5BFB5624C6D82E5F23F9F39692241B914400CA3693835AF06C004CC03C1891AB63FE29CFE8D642F16C088811C7AB1641140AED8FC98A69B1440F128BB4C88BC0DC0E5DEB060B82701400210B4FFABBE0840DD846EC5EFC6F6BFD1F256E5EC6C07C0CD8DB53DBB67FCBF8EB23092F9C5E8BFB79CF3959682C53FAACCCE84956DED3F77BF05118E5AFB3F24AB5563AB42F73F631DFA2C01A6F2BF96078048884185BF9A5C32EABE8BF2BF8563C8CBDA6EFEBFBCCA1B5B2B2615C0AAEA2C3BD6A20440CC89F96AB822F33F6D0FC4028E4A0AC0FAA9807B9EA512C0C05C0BE6A787194087CC5E0FC993F3BFB63DEF549CF30840EA09690984A208C0741E503075A60C4078FAFE7E894B01C0F953D46FC23CEE3F6BB4CD9FA362A63F7407F4A2AA30D43F939F288CF31715C0"> : tensor<20x20xf64>
    return %cst : tensor<20x20xf64>
  }
  func.func private @expected() -> (tensor<20x20xf64> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x5E89B6FDA494EBBF7CEB6893B646D7BFB4C179DABE53D3BFF267EE2E87FD004026D7D19FB4C8EBBFA1C57F69CA82EFBF98AF7EC0FFA5CEBFECF6688FD8CAEFBF2EF37D6CD719EFBF8A49654E2653F13F262F7F9604280B400A71A24B3571EEBF87F0B0F0B91F06403E68036F8DC8F33F861EB4035FFDEFBF9D0CAAD680EDA03FE219CD0F14C2F53FEF358EF72FE2EDBFEB83652FA0A3EEBF4EDD0797BC8CCF3FD355DD526D01EEBF30564A64FAD5C33F5528CB25AFF0EFBFDB5A7C2ACDB0EFBF2F88299586F5EFBFA22E33D8AC1E0D405696585B4263FE3F571CC11AE68CEFBF04B2F984BC97D2BF5D410BA8D6BDEFBF62F5E6134F6BEFBFFBC7272B1A19C13FD89A615E697C2A40D8FA9AF46702EEBF49C9FCCB48F9EABF7C82589C47A5EDBFFA39BA1ACA1DECBFD57982A581EBE9BF4EADFF6BA7E7EFBFF4A120A0DF2EEDBF54AD9EE2D453244084D5BD88346DEFBF80AD082868A8DABF4388C750497BBB407EFC2C1C97B35D40FA8A7C9E302FE4BF2ED0D006DC930E40CD83B2EE0DD60440761DE6A521C3D1BF04C8CD7E1B5F1440BE56DF5E28C12C40196F22E60FAF7440D0682CC7F315EFBFD703E28A704FEFBFB445A0466FDDEEBF49B882136C9BEFBF27271263D7BCEFBF607E0072C593E3BF2C6AC3C71D7DCBBFDE56C669E7D21B40C389974A49BD184036E6E8FC5C08E8BFB9C22D5C80F8134064466B542FB8EFBF529A3537DF80ED3F21CF0BD38D44EDBF7DB72466399EEFBF3837100DFB2B0740C46C6E915833F23FF405F0A7E8951940E7D9A6474ACC6F40E3D468AA7AC7E7BF8AB7205A0E72E5BF106C03C928C5DBBFE40FA6DA0710E5BFB146D449B343EFBF5FB5CEE5958290401E3ED1D2D60AE4BF10B929533AC1E9BF3FCA43355290EDBF50825ED079D8EDBF2C36869A806FF63FD871E76882F9EBBFC00072066D8DE3BF923A5618002D3F40F50EEE97EC7411406CE9ABDFE45CE9BF1E762F539713E6BF9DCAC2EA4D79924026C97B6172D0D6BF42B109F87995264065EB7AF27951E8BFC27F80C74E66E6BF02C66D087DCDDEBFC41D855EED6DAF3FA3716A302C232740ACB1A594DD66EFBF123E34782DD46C40A194E8ABB417D33FEE00CDE7E2C8F23F49C719645E913C409638D6091C0BFE3FA4DBF619816CDABFA876947AC221EEBF0F961861D1ACEFBFD067499C55D6ECBF005DD666C8B134401DB63EFA293FE8BFCFF2BDAB938EE8BFCE993CDAF319DFBF9863A03F5545EBBF7BA83FB890A8E8BF9AAE1BBB4D96EABFE70ED0AF6952EFBF2E6D447DF540E7BF974ED382B670EFBFAAB3B6DCF1E10240C6305E7A42D9F73FFEDE9B2D5EF7E9BF011D275E5F1DECBF943061F28A86EFBFCC9A4CA5E913E2BFD1B507D627A85740656F9C8AFD9E4A407859E628EED7EFBF92D51F74C6F4D0BF0E0643D07FE3E83FE258E8DBB89121403AEED0494026E3BF1C8272C7F9D60340B6F7DF43B9DA1E400B79CAB29A6CEBBF2EAFBDAC62AFB2BFAAFE3F2094FCE6BFDCC53FC1B2391040F358C9FF8B49E5BFAEA0B817A44EC73FA21A5054824A324038D639200B9CE7BF585E7DBFB58EE23FA936553574807440741F3E85EA97D7BF869DBAECBB8CE4BFAC5785DDCFA6EFBFD0CB3D9B8EFAE33F9ACD7AB228EAE6BFFEA1C5217316ED3F149A7B869104E8BF6B46506A4FC419401409556085A96040D1EC2E9D1A1EE4BFDFEFA751C5F2E2BF25ABB8685553504032CF8E27FCC6EE3F79CC9E95E19E18409203138EB87F9B3F8AF406BFA84A1740B5A22AC844F3EBBF8E9D11CA6C00F93F384BEBBB19E5274066BFD9294890EFBF5D3D1D40F3386540D77B2B60EA858A408C7024D7B92B9E3F9F6E9C43E1F9D5BF3FB517D8B610E43F161EAD705944A93F96921E815043EABFFA8C6C75B9FCE2BF9C1F6AC8ADB00E40A418771E3DF05C4080AE9D3F0F7F1340CBBEDABDFCE2EEBF1C4CBC1C203ADBBFCEA5A6425FEEB4BF08A7C798AE49ECBFBCF316CBAE44EDBFB729CF1592D5C9BF2978A2FB2C6EEFBF261D3EA16200FF3F7A1D90A87F535940A4F59E842EAFEEBFE2A124052C2AFA3F9ACBBB4DDF8FE4BF4C1937DF95B6DABFA5D19306657F414092FA485C189BEEBFF37919F01ABEEFBFA30B6CFBB79CEFBFECA225A395D90A4099EA5F3A7AFCEFBFC86A1C1AB4EB16400923E1C13B06EEBF9E2A16044EE7EFBFDEEDBF3E5D51E2BFA44C8244393CEBBF2BAF8F160B4431408C7AA4BFD926EABF42AAF5303B241A4080DB29DD28AAF03F14EB86110695DFBF3649029B8187DCBF6E14087F3FC6A93FFACFCF4B31EEE2BFB887196BC89EEFBFD80391635FDEE8BFCC9CEED1F9D61E40FF27BC7DF767EFBF76208B431EB73440BAA33A0F35FE0E400CB675F3A69D27401F6E6A7FFADAECBF58FE033F21954E401292137D579C254025B39D68B96B1640BC7FE65ACA11D6BF6F253C92298AEFBF0FF793ECA13E1340149EA5932557ECBF636C8ADFFCB75B40844502222E8CEFBFBE228B25FC0BE2BF828DC2860DF7E2BF96F87010C5D116409FDD289182EE1140EAA21F64632B3D4034724B13DFD6FD3FA62AD029AFC03B40BD95DB96978F1540E5FAF151CD4C01408A676789FC0D2840E7F3E0DCDAE4EDBF9CC7D2B8E7E0EFBF05C2F7993AD4EFBFC5CD355D0063EEBF1924C7C26C3BE9BF0CA782DC6DF5EFBF6E3719A536B03A404A9DBA53F8913F4026EE40B598C1EFBFF742828757DA17406EBFE2FBDF610040DF3A95939428EFBF5A85DB869AC3D5BF87DB6BBCDC51D8BF36E4FB738485EFBF689EE750803CFD3F0E0F44D6D8D1D33FBD0E00EE236BEFBFD54B05A4B849EABFCEA6C2FAC2114040C34707C244DDEFBFA4AE768659F6E6BF6E337F0E1553E6BFE6771EC35569164054989809738039402F34DC421068EEBFE0BA03C1503701402866FED5B1B81440FE64D8252EB7FE3F0C0DFAF4E8BBEEBF6107D1426895E3BF721C42B8F2730B4024551161FA8DE0BF08FCF6774AE6ECBF7C8CA39E6EDEEDBF70AC687EEE2B6B40782AE2BA181DEFBFE458A24072A4CDBF266D2FBF691FE63F2446120423BEE8BF928656D391BE5E40461785EF3530C93F40B36B616ED4E1BF0897DDA0D2B2EFBF12690675A090BB3FEFE27816D07CEFBFDED867BB5CBAE0BFDE9E5BA7EFEFEEBF1C6F6E43C7B55D4034CE60C36F68EFBF41AC0B130834ECBFDCB5E846C28EEFBF7F6361F25E6EEDBF0CDE54669380EDBF7F067E91AB2E7C403C643058E9AAECBF66D7EB9FFE0DCEBF840D43D52FE6E2BF339DDC3CD07A1B4002772A20974DFF3F30CDF4C472CEAEBF0D829941D5E9EEBFF999994B407DECBF501B7B9414DAEDBF348A4B6C680BDE3F5A4B91E95F6C0D40160623C7A7DD3440531CE91ECF09EFBFE70CFBDCA8F0903F6AE6F96052D98ABF16DAA2AFA360EBBFCEE739431D9BECBF2CD1038FF381C6BF89F51CD64CBE224046972E5DF7F52540DAF26AD1A19EF43F48BE6B027153A940223E70F36540724086CA7259EBE03D40BC0D819E0C5A06404575AD0F4B3CE8BFFB50EFE27BC5324029F0E64B9BE70540DEBFD4A5803CECBFBEA9E8B9F0F1EFBFC25D667224672440E8865BED3F49EEBFD9CF10763889EFBFFC0707005566E6BF42FB6F8676594840669A1D393FBB1740E9B39E15FF6A004046331534AE68FC3F40166286F337F43FFC697CD10842364082A632C80605EB3F207DB7EBD7C6E3BF9A2945ACC327EEBFE408F0154580E6BF0784353A65E0EEBF9A9A2E1CC9A7EDBF399FC5FEA8A5EFBFFFADF86FB8C517406520908914C17B4097BB58FC9143A93FD4041443A603F13F6AA95B332EA41E4016B4B65C7DA51B400D941904469C24401618C487F97F08405D4479DD7BA81540B104FCD66492EDBF5A4EAD463756EC3F0915F51C6E2330402E8634ADB2F4A8BF776D6E6FA61CE3BFBB37CC2AB9E6EFBF80427A71AF21EFBF826C03DBF7F87140BDB92732B7408A4095C6CDDB463E3E40CE7DD9FD72B7E9BF2C518B92A772CDBF13177DB0F0CAEABF1E5F9D815000E7BFAC02FB42806BE9BFE58096F0C6FFD6BFD684055E41F8194029CBF812800635404A2D1CF8CE09FA3F830A365EC542EFBFA59D5D54B4D0E7BF389D7915D80F0240C590F4730A1B66404AC704203E1FEEBFD4E5205F0216B73FBDBD300B09E0EFBF3D6D20245D16534072126A8BDE78654038743CE3E338EFBF7C07D3B8C1251E4072873CC69B0B3540263778A8EE4AE8BF9983FCFFC649EEBFDCE1C0F50A94EABF528997DAC43EE1BF89965D39516CC73FBA46D1533822F83F73303A3C701B12405A90651CE53B0A4021AD7D5E1406E6BF11C65028642585BFBE9C3978A7F5E5BF123B9EA74239EBBF54C7E9CE95D6EFBFC2A80237A0612840AF951E1B4C74024043371C8AB7CDEEBFC043D6D995B2EFBF640111981F738240C9BC414A1E96E6BF2291615E649F3540DE388B1C4287EEBF951A65AFAF75414001FA34C20851ECBFB0B342465E29F93F5F81E7B2C2E1A63F4AA8E918E4BCD73F4086939201D6EFBF"> : tensor<20x20xf64>
    return %cst : tensor<20x20xf64>
  }
}
