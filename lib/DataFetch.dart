import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:CustomUpstox/Home.dart';
import 'package:CustomUpstox/LogIn.dart';
import 'package:CustomUpstox/api_data_models/holdingmodal.dart';
import 'package:CustomUpstox/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:CustomUpstox/api_data_models/buysell.dart';
import 'package:CustomUpstox/api_data_models/charges.dart';
import 'package:CustomUpstox/secureStore.dart';
import 'package:http/http.dart' as http;
import 'package:CustomUpstox/auth/secrets.dart';
import 'package:intl/intl.dart';

class register_for_allrequests {
  Future<http.Response?> register(
    Uri pldata,
  ) async {
    String accesstoken = await secureStore().gettoken().then((value) {
      return value!;
    });
    http.Response? response;
    try {
      response = await http.get(
        pldata,
        headers: {
          HttpHeaders.acceptHeader: "application/json",
          'Api-Version': '2.0',
          HttpHeaders.authorizationHeader: 'Bearer $accesstoken'
        },
      );
      return response;
    } catch (e) {
      return await Future.delayed(Duration(milliseconds: 5000), () async {
        return await register(pldata);
      });
    }
  }
}

class DataFetch {
  Future<List<buySell>> realizedProfitLossList(String financialYear) async {
    final pldata = Uri.parse(
        'https://api-v2.upstox.com/trade/profit-loss/data?segment=EQ&financial_year=$financialYear&page_number=1&page_size=3000');

    http.Response? par = await register_for_allrequests().register(pldata);
    late Map<String, dynamic> temp = jsonDecode(par!.body);
    List<Map<String, dynamic>> parsed =
        (temp["data"] as List).map((e) => e as Map<String, dynamic>).toList();
    List<buySell> bsList = [];
    for (int i = 0; i < parsed.length; i++) {
      buySell bs_obj = buySell(
        parsed[i]["scrip_name"],
        parsed[i]["trade_type"],
        parsed[i]["buy_date"],
        parsed[i]["quantity"],
        parsed[i]["buy_average"],
        parsed[i]["sell_date"],
        parsed[i]["sell_average"],
        parsed[i]["financialYear"],
        parsed[i]["isin"],
      );
      bsList.add(bs_obj);
      await SessionManager().set("bs+$i+obj+$financialYear", bs_obj);
    }
    await SessionManager().set("plListsize$financialYear", parsed.length);
    return bsList;
  }

//------------------------------------------------------------------------------------------------------------
  Future<int> profitLossDataCount(String financialYear) async {
    final pldatacount = Uri.parse(
        'https://api.upstox.com/v2/trade/profit-loss/metadata?start_date=01-04-2022&emd_date=30-03-2023&segment=EQ&financial_year=$financialYear');

    http.Response? par = await register_for_allrequests().register(pldatacount);
    late Map<String, dynamic> parsed = jsonDecode(par!.body);
    int tradecount = parsed["trades_count"];
    return tradecount;
  }
//---------------------------------------------------------------------------------------------------------------------------

  Future<charges_obj> charges_forfin(String financialYear) async {
    final charges = Uri.parse(
        'https://api.upstox.com/v2/trade/profit-loss/charges?&financial_year=$financialYear&segment=EQ');

    http.Response? par = await register_for_allrequests().register(charges);
    late Map<String, dynamic> parsed = jsonDecode(par!.body);
    if (parsed["status"] == "error") {
      secureStore().deleteall();
      secureStore().setDate("");
      return defaultchargeObj().defaultChargeObj;
    } else {
      parsed = parsed["data"];
      Map<String, dynamic> taxes = parsed["charges_breakdown"]["taxes"];
      Map<String, dynamic> otherCharge = parsed["charges_breakdown"]["charges"];

      charges_obj charge = charges_obj(
          parsed["charges_breakdown"]["total"],
          parsed["charges_breakdown"]["brokerage"],
          taxes["gst"],
          taxes["stt"],
          taxes["stamp_duty"],
          otherCharge["transaction"],
          otherCharge["clearing"],
          otherCharge["others"],
          otherCharge["sebi_turnover"],
          otherCharge["demat_transaction"],
          financialYear,
          true);
      return charge;
    }
  }

  //------------------------------------------------------------------------------------------------------------------
  Future<List<charges_obj>> charges_for_all_financial_year() async {
    var yearStart = secrets().yearStart;
    var yearEnd = secrets().yearEnd;
    var currentyear = num.parse(secrets().currentyear) + 2;
    var arr = <Future>[];
    List<charges_obj> list = [];
    var fi = [];
    while (yearStart != currentyear) {
      String fy = yearStart.toString() + yearEnd.toString();
      arr.add(charges_forfin(fy));
      fi.add(fy);
      yearStart++;
      yearEnd++;
    }
    List<dynamic> response = await Future.wait(arr);
    for (int i = 0; i < response.length; i++) {
      list.add(response[i]);
      await SessionManager().set("charge${fi[i]}", response[i]);
    }
    await SessionManager().set("listSize", list.length);
    await SessionManager().set("chargelist", true);
    return list;
  }
}

//----------------------------------------------------------------------------------------------------------------------------
Future<List<List<buySell>>> buysell_for_all_financial_year() async {
  var yearStart = secrets().yearStart;
  var yearEnd = secrets().yearEnd;
  DateFormat format = DateFormat("dd-MM-yyyy");

  int listLength = await SessionManager().get("listSize");
  List<List<buySell>> ans = [];
  int i = 0;
  var arr = <Future>[];
  while (i < listLength) {
    String fy = yearStart.toString() + yearEnd.toString();
    arr.add(DataFetch().realizedProfitLossList(fy));
    i++;
    yearStart++;
    yearEnd++;
  }
  List<dynamic> response = await Future.wait(arr);
  for (List<buySell> element in response) {
    List<buySell> list = [];
    for (var e in element) {
      list.add(e);
    }
    list.sort((a, b) => format
        .parse(a.sellDate.toString())
        .compareTo(format.parse(b.sellDate.toString())));
    ans.add(list);
  }
  // await SessionManager().set("tradecount", list.length);
  await SessionManager().set("plList", true);
  return ans;
}

//----------------------------------------------------------------------------------------------------------------------------
Future<List<charges_obj>> fetchsessionchargeobj() async {
  var yearStart = secrets().yearStart;
  var yearEnd = secrets().yearEnd;
  List<charges_obj> list = [];
  var length = await SessionManager().get("listSize");
  int i = 0;
  var arr = <Future>[];
  while (i < length) {
    String fy = yearStart.toString() + yearEnd.toString();
    Map<String, dynamic> temp =
        await SessionManager().get("charge$fy").then((value) {
      return value;
    });
    if (temp == null) continue;
    charges_obj obj = jsoncharges().fromJson(temp);
    list.add(obj);
    i++;
    yearStart++;
    yearEnd++;
  }
  return list;
}

Future<List<List<buySell>>> fetchsessionProfitLossobj() async {
  var yearStart = secrets().yearStart;
  var yearEnd = secrets().yearEnd;
  List<List<buySell>> list = [];
  var length = await SessionManager().get("listSize");
  int i = 0;
  while (i < length) {
    String fy = yearStart.toString() + yearEnd.toString();
    int parsedlength = await SessionManager().get("plListsize$fy");
    List<buySell> bslist = [];
    for (int j = 0; j < parsedlength; j++) {
      Map<String, dynamic> temp =
          await SessionManager().get("bs+$j+obj+$fy").then((value) {
        return value;
      });
      buySell bsobj = jsonBuySell().fromJson(temp);
      bslist.add(bsobj);
    }
    // buySell obj = jsonBuySell().fromJson(temp);
    list.add(bslist);
    i++;
    yearStart++;
    yearEnd++;
  }
  return list;
}

//------------------------------------------------------ Fetch Holdings Data--------------------------------------------

class fetchHoldingData {
  Future<List<holdingmodal>> fetchholding() async {
    List<holdingmodal> templist = [];
    Uri holdinguri =
        Uri.parse('https://api.upstox.com/v2/portfolio/long-term-holdings');
    http.Response? parsed =
        await register_for_allrequests().register(holdinguri);

    Map<String, dynamic> temp = jsonDecode(parsed!.body);
    if (temp["data"] == null) return templist;
    List<Map<String, dynamic>> pas =
        (temp["data"] as List).map((e) => e as Map<String, dynamic>).toList();
    for (int i = 0; i < pas.length; i++) {
      holdingmodal hold = holdingmodal(
          pas[i]["company_name"],
          pas[i]["quantity"],
          pas[i]["last_price"],
          pas[i]["pnl"],
          pas[i]["average_price"],
          pas[i]["tradingsymbol"],
          const ObjectKey('obj'));
      templist.add(hold);
    }
    templist.sort(((a, b) => a.company_name.compareTo(b.company_name)));
    return templist;
  }

  Future<List<holdingmodal>> fakedata(int i) async {
    List<holdingmodal> templist = [];
    templist.add(holdingmodal("company_name", 20, 100 * i, 501 * i, 652,
        "trading_symbol", ObjectKey('obj')));
    return templist;
  }
}
