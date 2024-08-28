// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt > %t.0
// RUN: stablehlo-opt %s > %t.1
// RUN: diff %t.0 %t.1

module @jit_main attributes {mhlo.num_partitions = 1 : i32, mhlo.num_replicas = 1 : i32} {
  func.func public @main() -> (tensor<1x125xf32> {jax.result_info = "", mhlo.layout_mode = "default"}) {
    %c = stablehlo.constant dense<0> : tensor<1xi64>
    %0:2 = call @inputs() : () -> (tensor<1x125xf32>, tensor<1xf32>)
    %1 = call @expected() : () -> tensor<1x125xf32>
    %2 = "stablehlo.scatter"(%0#0, %c, %0#1) <{scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true}> ({
    ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):
      %3 = stablehlo.multiply %arg0, %arg1 : tensor<f32>
      stablehlo.return %3 : tensor<f32>
    }) : (tensor<1x125xf32>, tensor<1xi64>, tensor<1xf32>) -> tensor<1x125xf32>
    stablehlo.custom_call @check.expect_close(%2, %1) {has_side_effect = true} : (tensor<1x125xf32>, tensor<1x125xf32>) -> ()
    return %2 : tensor<1x125xf32>
  }
  func.func private @inputs() -> (tensor<1x125xf32> {mhlo.layout_mode = "default"}, tensor<1xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0xB44704C01DEC424005207F3EA6AB8D3F1BB1CBC0993100BECAF2BDBE8510ECBFE80472BF1689D4BF1C4EC63D1ED9C040632CB3BFFAF7813FB2CF14405E9790BF28D7AF3F275B2CC0F5C3D13FC77389C0847C3740AF30343D05F00EC0896AB13F7CAA87BF653327405D8D3FC0815E7640D1B0684005A933BEBC0AB5BEBDF16140FDFAE33F473143BFCC0CB3BFEE0E453F3C028B3F05FC0DC098F7DDC077B7EABF5978DC3E7FA58F4001115DBFCDF8253F0C40C0BF794CF33ECF6EF9BF7C0E6A3F91508B40FC2C41408E850640EFCDA3BF661F34C0B66F3B40F4ED5B40AA514DC079DF18C02EE703408F597DC09466D6400DD230402903B3400A091E401DA423BF9B913B3FD9DB15C060A5813F73BDC6C09A0369BEA7D988BFC28064BCA1AEFD3E3822C83DCE6C4D400B6558C04872BB40EA01984077F64DC08F7B15C0A3FE743FF37033C0762CA840235615C0B035B4C0A33BE7C00EBB3FC01130A1BF9EA622C0A09C65C0868D1A4026553CC0FCC750C0BE7957408F214C4078B4523F338E21406EB7993D8C380140122D3CBFD10303C1D6BB81C082410940525D3E40F2DB31409FA757406D4F374086458FC0D14502C17393873FDF844CC0544C7DC06D5169C0C2687E40A974DD3F20D6F8BF287F7F40AF5601BF4DB7C23F4EEA1CBF73840040E71281C07769973F853F24C09CC5A2C081267540"> : tensor<1x125xf32>
    %cst_0 = stablehlo.constant dense<1.50476873> : tensor<1xf32>
    return %cst, %cst_0 : tensor<1x125xf32>, tensor<1xf32>
  }
  func.func private @expected() -> (tensor<1x125xf32> {mhlo.layout_mode = "default"}) {
    %cst = stablehlo.constant dense<"0x0B0D47C01DEC424005207F3EA6AB8D3F1BB1CBC0993100BECAF2BDBE8510ECBFE80472BF1689D4BF1C4EC63D1ED9C040632CB3BFFAF7813FB2CF14405E9790BF28D7AF3F275B2CC0F5C3D13FC77389C0847C3740AF30343D05F00EC0896AB13F7CAA87BF653327405D8D3FC0815E7640D1B0684005A933BEBC0AB5BEBDF16140FDFAE33F473143BFCC0CB3BFEE0E453F3C028B3F05FC0DC098F7DDC077B7EABF5978DC3E7FA58F4001115DBFCDF8253F0C40C0BF794CF33ECF6EF9BF7C0E6A3F91508B40FC2C41408E850640EFCDA3BF661F34C0B66F3B40F4ED5B40AA514DC079DF18C02EE703408F597DC09466D6400DD230402903B3400A091E401DA423BF9B913B3FD9DB15C060A5813F73BDC6C09A0369BEA7D988BFC28064BCA1AEFD3E3822C83DCE6C4D400B6558C04872BB40EA01984077F64DC08F7B15C0A3FE743FF37033C0762CA840235615C0B035B4C0A33BE7C00EBB3FC01130A1BF9EA622C0A09C65C0868D1A4026553CC0FCC750C0BE7957408F214C4078B4523F338E21406EB7993D8C380140122D3CBFD10303C1D6BB81C082410940525D3E40F2DB31409FA757406D4F374086458FC0D14502C17393873FDF844CC0544C7DC06D5169C0C2687E40A974DD3F20D6F8BF287F7F40AF5601BF4DB7C23F4EEA1CBF73840040E71281C07769973F853F24C09CC5A2C081267540"> : tensor<1x125xf32>
    return %cst : tensor<1x125xf32>
  }
}
