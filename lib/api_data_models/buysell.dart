import 'package:CustomUpstox/api_data_models/charges.dart';

// ignore: camel_case_types
class buySell {
  var scripName, tradeType, buyDate;
  num quantity, buyAverage;
  var sellDate;
  num sellAverage;
  var financialYear, isin;

  buySell(
      this.scripName,
      this.tradeType,
      this.buyDate,
      this.quantity,
      this.buyAverage,
      this.sellDate,
      this.sellAverage,
      this.financialYear,
      this.isin,
);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> buysell = Map<String, dynamic>();
    buysell["scripName"] = scripName;
    buysell["tradeType"] = tradeType;
    buysell["buyDate"] = buyDate;
    buysell["quantity"] = quantity;
    buysell["buyAverage"] = buyAverage;
    buysell["sellDate"] = sellDate;
    buysell["sellAverage"] = sellAverage;
    buysell["financialYear"] = financialYear;
    buysell["isin"] = isin;
   
    return buysell;
  }
}

class jsonBuySell {
  buySell fromJson(Map<String, dynamic> buysell) {
    final buySell buySell_obj = buySell(
        buysell["scripName"],
        buysell["tradeType"],
        buysell["buyDate"],
        buysell["quantity"],
        buysell["buyAverage"],
        buysell["sellDate"],
        buysell["sellAverage"],
        buysell["financialYear"],
        buysell["isin"]
   );
    return buySell_obj;
  }

  Future<List<List<num>>> buysellTotal(
    List<List<buySell>> bs,
  ) async {
    List<List<num>> ans = [];
    num buy = 0, sell = 0;
    for (List<buySell> bslist in bs) {
      List<num> pl = [0, 0];
      if (bslist.isNotEmpty) {
        for (buySell obj in bslist) {
          buy = bslist.fold(0,
              (sum, element) => sum + (element.quantity * element.buyAverage));
          sell = bslist.fold(
              0, (sum, item) => sum + (item.quantity * item.sellAverage));
        }
        pl[0] = (buy * 100).round() / 100.00;
        pl[1] = (sell * 100).round() / 100.00;
      }
      ans.add(pl);
    }
   
    return ans;
  }

  Future<List<num>> allyearreturn(
      List<charges_obj> chargelist, List<List<num>> buysell) async {
    num buy = 0, sell = 0, charges = 0;
    buy = buysell.fold(0, (item, element) => item + element[0]);
    sell =
        buysell.fold(0, (previousValue, element) => previousValue + element[1]);
    charges = chargelist.fold(
        0, (previousValue, element) => previousValue + element.total);
    List<num> overallvalues = [];
    overallvalues.add(buy);
    overallvalues.add(sell);
    overallvalues.add(charges);
    num retu = ((sell - buy - charges) * 100).round() / 100;
    overallvalues.add(retu);
    return overallvalues;
  }
}