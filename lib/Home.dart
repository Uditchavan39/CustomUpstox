import 'package:CustomUpstox/LogIn.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:CustomUpstox/api_data_models/buysell.dart';
import 'package:CustomUpstox/api_data_models/charges.dart';
import 'package:CustomUpstox/bottomSheet.dart';
import 'package:intl/intl.dart';
import 'DataFetch.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime date = DateTime.now();
  late List<charges_obj> chargelist = [];
  late List<List<buySell>> plList = [];
  late List<List<num>> buysell = []; // 0th value buy and 1st value sell;
  late List<num> overallreturns = [
    0,
    0,
    0,
    0
  ]; //0th value Totalbuy , 1st Value Totalsell ,2nd Value TotalCharges, 3rd value TotalReturn;
  var subscription;
  late var isOnline = ConnectivityResult.none;
  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (mounted) {
        setState(() {
          isOnline = result;
          showsnackbar();
        });
      }
    });
    fetchchargedata();
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void fetchpldata() async {
    bool sessionplcheck = await SessionManager().containsKey("plList");
    if (!sessionplcheck) {
      plList = await buysell_for_all_financial_year().then((value) {
        return value;
      });
      await SessionManager().set("plList", true);
    } else {
      plList = await fetchsessionProfitLossobj().then((value) {
        return value;
      });
      if (mounted) {
        setState(() {
          plList = plList;
        });
      }
    }
    buysell = await jsonBuySell().buysellTotal(plList).then((value) {
      return value;
    });
    if (mounted) {
      setState(() {
        buysell = buysell;
      });
    }
    overallreturns =
        await jsonBuySell().allyearreturn(chargelist, buysell).then((value) {
      return value;
    });
    if (mounted) {
      setState(() {
        overallreturns = overallreturns;
      });
    }
  }

  void fetchchargedata() async {
    bool sessionchargecheck = await SessionManager().containsKey("chargelist");
    if (!sessionchargecheck) {
      chargelist =
          await DataFetch().charges_for_all_financial_year().then((value) {
        return value;
      });
    } else {
      chargelist = await fetchsessionchargeobj().then((value) {
        return value;
      });
      if (mounted) {
        setState(() {
          chargelist = chargelist;
        });
      }
    }
    fetchpldata();
  }

  void showsnackbar() {
    SnackBar snackBar = const SnackBar(
      content: Text("No Internet Connection!"),
      duration: Duration(hours: 1),
    );
    if (isOnline != ConnectivityResult.mobile &&
        isOnline != ConnectivityResult.wifi &&
        isOnline != ConnectivityResult.vpn) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<List<num>> bs = buysell;
    List<num> total = overallreturns;
    List<charges_obj> chargelist = this.chargelist;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          backgroundColor: Colors.deepPurple,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        bottomSheet: chargelist.isNotEmpty
            ? CustomDataBottomrow(
                Totalbuy: total[0],
                Totalsell: total[1],
                Totalcharges: total[2],
                TotalReturn: total[3],
              )
            : null,
        body: chargelist.isNotEmpty && buysell.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 65),
                scrollDirection: Axis.vertical,
                itemCount: chargelist.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return const CustomDataHeadrow();
                  return Material(
                    color: CustomDatarow(
                            financialYear: chargelist[index - 1].financial_year,
                            buy: bs[index - 1][0],
                            sell: bs[index - 1][1],
                            charges: chargelist[index - 1].total)
                        .colorcheck(),
                    child: InkWell(
                      splashColor: CustomDatarow(
                              financialYear:
                                  chargelist[index - 1].financial_year,
                              buy: bs[index - 1][0],
                              sell: bs[index - 1][1],
                              charges: chargelist[index - 1].total)
                          .splashcolor(),
                      onTap: () {
                        showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return bottomSheet(
                                index: index,
                                bslist: plList[index - 1],
                                financialYear:
                                    chargelist[index - 1].financial_year,
                                TotalBuy: bs[index - 1][0],
                                TotalCharges: chargelist[index - 1].total,
                                TotalSell: bs[index - 1][1],
                              );
                            },
                            backgroundColor: Colors.indigo,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer);
                      },
                      child: CustomDatarow(
                          financialYear: chargelist[index - 1].financial_year,
                          buy: bs[index - 1][0],
                          sell: bs[index - 1][1],
                          charges: chargelist[index - 1].total),
                    ),
                  );
                })
            : ListView.builder(
                itemCount: 6,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return const CustomDataHeadrow();
                  return Shimmer(
                    direction: const ShimmerDirection.fromLTRB(),
                    color: Colors.white,
                    colorOpacity: 0.5,
                    child: shimmercontainer(),
                  );
                }));
  }
}

class CustomDataHeadrow extends StatelessWidget {
  const CustomDataHeadrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.purple.shade100,
      height: 60,
      child: Row(children: [
        Container(
            width: MediaQuery.of(context).size.width / 4,
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: const Text(
              "Financial\n Year",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: const Text(
              "BUY",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: const Text(
              "SELL",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: const Text(
              "Charges",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
      ]),
    );
  }
}

class CustomDatarow extends StatelessWidget {
  CustomDatarow(
      {super.key,
      required this.financialYear,
      required this.buy,
      required this.sell,
      required this.charges});
  final String financialYear;
  final num buy;
  final num sell;
  num charges;

  Color colorcheck() {
    var temp = sell - buy - charges;
    if (temp > 0) {
      return Colors.green.shade100;
    } else if (temp == 0) {
      return Colors.white30;
    } else {
      return Colors.red.shade100;
    }
  }

  Color splashcolor() {
    var temp = sell - buy - charges;
    if (temp > 0) {
      return Colors.greenAccent;
    } else if (temp == 0) {
      return Colors.grey.shade400;
    } else {
      return Colors.redAccent.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: colorcheck(),
      height: 50,
      child: Row(children: [
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Text(
              "${financialYear.substring(0, 2)}-${financialYear.substring(2)}",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Text(
              buy > 99999
                  ? currencyconverter()
                      .indianRupeesFormatCompact
                      .format(buy)
                      .toString()
                  : currencyconverter()
                      .indianRupeesFormat
                      .format(buy)
                      .toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: Text(
              sell > 99999
                  ? currencyconverter()
                      .indianRupeesFormatCompact
                      .format(sell)
                      .toString()
                  : currencyconverter()
                      .indianRupeesFormat
                      .format(sell)
                      .toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
        Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black))),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: Text(
              charges > 99999
                  ? currencyconverter()
                      .indianRupeesFormatCompact
                      .format(charges)
                      .toString()
                  : currencyconverter()
                      .indianRupeesFormat
                      .format(charges)
                      .toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
      ]),
    );
  }
}

class shimmercontainer extends StatelessWidget {
  shimmercontainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      width: MediaQuery.of(context).size.width / 3,
      height: MediaQuery.of(context).size.height / 10,
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Row(children: [
        Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: const Text(
              "",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
        Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: const Text(
              "",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
        Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: const Text(
              "",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
        Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: const Text(
              "",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            )),
      ]),
    );
  }
}

class currencyconverter {
  final indianRupeesFormat = NumberFormat.currency(
    name: "INR",
    locale: 'en_IN',
    decimalDigits: 2, // change it to get decimal places
    symbol: '',
  );

  final indianRupeesFormatCompact = NumberFormat.compactCurrency(
    name: "INR",
    locale: 'en_IN',
    decimalDigits: 2, // change it to get decimal places
    symbol: '',
  );
}

class CustomDataBottomrow extends StatefulWidget {
  const CustomDataBottomrow(
      {super.key,
      required this.Totalbuy,
      required this.Totalsell,
      required this.Totalcharges,
      required this.TotalReturn});
  final num Totalbuy;
  final num Totalsell;
  final num Totalcharges;
  final num TotalReturn;

  @override
  State<CustomDataBottomrow> createState() => _CustomDataBottomrowState();
}

class _CustomDataBottomrowState extends State<CustomDataBottomrow> {
  Color colorcheck(num temp) {
    if (temp > 0) {
      return Colors.green.shade100;
    } else if (temp == 0) {
      return Colors.white30;
    } else {
      return Colors.red.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 65,
      child: Row(children: [
        Container(
            width: MediaQuery.of(context).size.width / 4,
            decoration: BoxDecoration(
                border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black)),
                color: colorcheck(widget.Totalsell - widget.Totalbuy)),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.Totalbuy.abs() > 99999
                      ? currencyconverter()
                          .indianRupeesFormatCompact
                          .format(widget.Totalbuy)
                          .toString()
                      : currencyconverter()
                          .indianRupeesFormat
                          .format(widget.Totalbuy)
                          .toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Buy",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )),
        Container(
            decoration: BoxDecoration(
                border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black)),
                color: colorcheck(widget.Totalsell - widget.Totalbuy)),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.Totalsell.abs() > 99999
                      ? currencyconverter()
                          .indianRupeesFormatCompact
                          .format(widget.Totalsell)
                      : currencyconverter()
                          .indianRupeesFormat
                          .format(widget.Totalsell)
                          .toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Sell",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )),
        Container(
            decoration: BoxDecoration(
                border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black)),
                color: colorcheck(-1 * widget.Totalcharges)),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.Totalcharges.abs() > 99999
                      ? currencyconverter()
                          .indianRupeesFormatCompact
                          .format(widget.Totalcharges)
                      : currencyconverter()
                          .indianRupeesFormat
                          .format(widget.Totalcharges)
                          .toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Charges",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )),
        Container(
            decoration: BoxDecoration(
                border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black)),
                color: colorcheck(widget.TotalReturn)),
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.TotalReturn.abs() > 99999
                      ? currencyconverter()
                          .indianRupeesFormatCompact
                          .format(widget.TotalReturn)
                      : currencyconverter()
                          .indianRupeesFormat
                          .format(widget.TotalReturn)
                          .toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Total Return",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )),
      ]),
    );
  }
}
