import 'dart:async';
import 'dart:math';

import 'package:CustomUpstox/DataFetch.dart';
import 'package:CustomUpstox/api_data_models/holdingmodal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../Home.dart';

class Holdings extends StatefulWidget {
  const Holdings({super.key});

  @override
  State<Holdings> createState() => _HoldingsState();
}

class _HoldingsState extends State<Holdings> {
  List<holdingmodal> holdlist = [];
  Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  num invested = 0;
  num curval = 0;
  num allpnl = 0;
  Timer timer = Timer(const Duration(milliseconds: 1), () {});
  @override
  void dispose() {
    _timer.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    foo();
    super.initState();
  }

  num foe(int index) {
    return holdlist[index].pnl;
  }

  void foo() async {
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (_timer) async {
      List<holdingmodal> _holdlist =
          await fetchHoldingData().fetchholding().then((value) {
        return value;
      });
      if (_holdlist.isNotEmpty) {
        num _invested;
        if (invested == 0) {
          _invested = _holdlist.fold(
              0,
              (previousValue, element) =>
                  previousValue + (element.avg_price * element.quantity));
          if (mounted) {
            setState(() {
              invested = _invested;
            });
          }
        }
        num _curval = _holdlist.fold(
            0,
            (previousValue, element) =>
                previousValue + (element.last_price * element.quantity));
        num _allpnl = _holdlist.fold(
            0, (previousValue, element) => previousValue + element.pnl);
        if (mounted) {
          setState(() {
            holdlist = List.from(_holdlist);
            curval = _curval;
            allpnl = _allpnl;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    num val = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Holdings"),
        backgroundColor: Colors.deepPurple,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
      ),
      body: holdlist.isEmpty
          ? ListView.builder(
              itemCount: 6,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Shimmer(
                  direction: const ShimmerDirection.fromLTRB(),
                  color: Colors.white,
                  colorOpacity: 0.5,
                  child: shimmercontainer(),
                );
              })
          : ListView.builder(
              itemCount: holdlist.length + 1,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                if (index == holdlist.length) {
                  return totalreturnholding(
                    invested: invested,
                    curval: curval,
                    pnl: allpnl,
                  );
                }
                return Material(
                  child: InkWell(
                    splashColor: Colors.blue.shade50,
                    onTap: () {
                      _timer.cancel();
                      showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return holdingbottomsheet(
                                    Company_name: holdlist[index].company_name,
                                    quantity: holdlist[index].quantity,
                                    last_price: holdlist[index].last_price,
                                    pnl: holdlist[index].pnl,
                                    avg_price: holdlist[index].avg_price,
                                    index: index);
                              },
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer)
                          .then((value) {
                        foo();
                      });
                    },
                    child: holdingforholdings(
                      trading_symbol: holdlist[index].trading_symbol,
                      trading_quantity: holdlist[index].quantity,
                      avg_price: holdlist[index].avg_price,
                      pnl: holdlist[index].pnl,
                    ),
                  ),
                );
              }),
    );
  }
}

class holdingforholdings extends StatefulWidget {
  const holdingforholdings({
    super.key,
    required this.trading_symbol,
    required this.trading_quantity,
    required this.avg_price,
    required this.pnl,
  });
  final String trading_symbol;
  final num trading_quantity;
  final num avg_price;
  final num pnl;
  @override
  State<holdingforholdings> createState() => _holdingforholdingsState();
}

class _holdingforholdingsState extends State<holdingforholdings> {
  Color _colorfill = Colors.grey.shade300, _bordercolor = Colors.black;
  double percent = 0;
  @override
  void initState() {
    super.initState();
  }

  double percentcalculate() {
    num invested = widget.trading_quantity * widget.avg_price;
    if (invested != 0) {
      percent = (widget.pnl / invested);
    } else {
      percent = 0;
    }
    String str = percent.toStringAsFixed(4);
    percent = double.parse(str);
    if (percent > 0) {
      _colorfill = Colors.greenAccent;
      _bordercolor = Colors.green;
    } else if (percent == 0) {
      _colorfill = Colors.grey.shade300;
      _bordercolor = Colors.black;
    } else {
      _colorfill = Colors.redAccent;
      _bordercolor = Colors.red;
    }
    return percent;
  }

  @override
  Widget build(BuildContext context) {
    double _percent = percentcalculate();
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: (MediaQuery.of(context).size.width / 2) * 0.96,
                  child: Text(
                    widget.trading_symbol,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width / 2) * 0.96,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Q : ${widget.trading_quantity}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: _bordercolor, width: 2.5),
                  borderRadius:
                      const BorderRadius.all(Radius.elliptical(22, 25))),
              child: LinearPercentIndicator(
                animation: true,
                padding: const EdgeInsets.all(0),
                animateFromLastPercent: true,
                animationDuration: 1000,
                lineHeight: 50.0,
                backgroundColor: Colors.grey.shade100,
                progressColor: _colorfill,
                percent: _percent.abs() > 1.0 ? 1.0 : _percent.abs(),
                center: Text(
                  "${(_percent * 100).toStringAsFixed(2)}%",
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                ),
                barRadius: const Radius.circular(20),
              ),
            ),
          ],
        ));
  }
}

class totalreturnholding extends StatefulWidget {
  const totalreturnholding(
      {super.key,
      required this.invested,
      required this.curval,
      required this.pnl});
  final num invested;
  final num curval;
  final num pnl;
  @override
  State<totalreturnholding> createState() => _totalreturnholdingState();
}

class _totalreturnholdingState extends State<totalreturnholding> {
  Color _colorfill = Colors.grey.shade300, _bordercolor = Colors.black;
  double percent = 0;
  @override
  void initState() {
    super.initState();
  }

  double percentcalculate() {
    if (widget.invested != 0) {
      percent = (widget.pnl / widget.invested);
    } else {
      percent = 0;
    }
    String str = percent.toStringAsFixed(4);
    percent = double.parse(str);
    if (percent > 0) {
      _colorfill = Colors.greenAccent;
      _bordercolor = Colors.green;
    } else if (percent == 0) {
      _colorfill = Colors.grey.shade300;
      _bordercolor = Colors.black;
    } else {
      _colorfill = Colors.redAccent;
      _bordercolor = Colors.red;
    }
    return percent;
  }

  @override
  Widget build(BuildContext context) {
    double _percent = percentcalculate();
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
            color: Colors.purple.shade100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    width: (MediaQuery.of(context).size.width / 2) * 0.96,
                    child: Text(
                      "Invested \n${widget.invested > 99999 ? currencyconverter().indianRupeesFormatCompact.format(widget.invested).toString() : currencyconverter().indianRupeesFormat.format(widget.invested).toString()}",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    )),
                Container(
                    width: (MediaQuery.of(context).size.width / 2) * 0.96,
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Current Val \n ${widget.curval > 99999 ? currencyconverter().indianRupeesFormatCompact.format(widget.curval).toString() : currencyconverter().indianRupeesFormat.format(widget.curval).toString()}",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: _bordercolor, width: 2.5),
                  borderRadius:
                      const BorderRadius.all(Radius.elliptical(22, 25))),
              child: LinearPercentIndicator(
                animation: true,
                padding: const EdgeInsets.all(0),
                animateFromLastPercent: true,
                animationDuration: 700,
                lineHeight: 50.0,
                backgroundColor: Colors.grey.shade100,
                progressColor: _colorfill,
                percent: _percent.abs() > 1.0 ? 1.0 : _percent.abs(),
                center: Text(
                  "${(_percent * 100).toStringAsFixed(2)}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                barRadius: const Radius.circular(20),
              ),
            ),
          ],
        ));
  }
}

class holdingbottomsheet extends StatefulWidget {
  const holdingbottomsheet(
      {super.key,
      required this.Company_name,
      required this.quantity,
      required this.last_price,
      required this.pnl,
      required this.avg_price,
      required this.index});
  final String Company_name;
  final num quantity;
  final num last_price;
  final num pnl;
  final num avg_price;
  final int index;
  @override
  State<holdingbottomsheet> createState() => _holdingbottomsheetState();
}

class _holdingbottomsheetState extends State<holdingbottomsheet> {
  num lastprice = 0, profitnloss = 0;
  double percent = 0;
  late Color colorforindicator;
  bool reverse = false;
  Timer timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {});
  Color colorcheck(num temp) {
    if (temp > 0) {
      return Colors.green;
    } else if (temp == 0) {
      return Colors.grey.shade100;
    } else {
      reverse = true;
      return Colors.red;
    }
  }

  double percentcal() {
    if (widget.avg_price != 0) {
      percent = (profitnloss / (widget.avg_price * widget.quantity));
    } else {
      percent = 0;
    }
    String str = percent.toStringAsFixed(4);
    percent = double.parse(str);
    return percent;
  }

  @override
  void initState() {
    lastprice = widget.last_price;
    profitnloss = widget.pnl;
    foo();
    percent = percentcal();
    colorforindicator = colorcheck(widget.pnl);
    super.initState();
  }

  void foo() async {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      List<holdingmodal> _list =
          await fetchHoldingData().fetchholding().then((value) {
        return value;
      });
      if (mounted) {
        setState(() {
          lastprice = _list[widget.index].last_price;
          profitnloss = _list[widget.index].pnl;
          percent = percentcal();
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    num invested = widget.avg_price * widget.quantity;
    num curval = invested + profitnloss;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.Company_name,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.white30,
                    border: Border(
                        top: BorderSide(width: 1, color: Colors.black),
                        bottom: BorderSide(width: 1, color: Colors.black))),
                child: Column(
                  children: [
                    Row(children: [
                      Container(
                        alignment: Alignment.topLeft,
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          invested < 99999
                              ? "Invested \n${currencyconverter().indianRupeesFormat.format(invested).toString()}"
                              : "Invested \n${currencyconverter().indianRupeesFormatCompact.format(invested).toString()}",
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(right: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          curval < 99999
                              ? "Current Value \n${currencyconverter().indianRupeesFormat.format(curval).toString()}"
                              : "Current Value \n${currencyconverter().indianRupeesFormatCompact.format(curval).toString()}",
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: colorforindicator),
                        ),
                      )
                    ]),
                    Row(children: [
                      Container(
                        alignment: Alignment.topLeft,
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          widget.quantity < 99999
                              ? "Quantity \n ${currencyconverter().indianRupeesFormat.format(widget.quantity).toString()}"
                              : "Quantity \n ${currencyconverter().indianRupeesFormatCompact.format(widget.quantity).toString()}",
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(right: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          widget.avg_price < 99999
                              ? "Avg Price \n ${currencyconverter().indianRupeesFormat.format(widget.avg_price).toString()}"
                              : "Avg Price \n ${currencyconverter().indianRupeesFormatCompact.format(widget.avg_price).toString()}",
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Container(
                        alignment: Alignment.topLeft,
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          profitnloss < 99999
                              ? "Profit/Loss \n ${currencyconverter().indianRupeesFormat.format(profitnloss).toString()}"
                              : "Profit/Loss \n ${currencyconverter().indianRupeesFormatCompact.format(profitnloss).toString()}",
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorforindicator),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width / 2,
                        padding: const EdgeInsets.only(right: 10),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          lastprice < 99999
                              ? "LTP \n ${currencyconverter().indianRupeesFormat.format(lastprice).toString()}"
                              : "LTP \n ${currencyconverter().indianRupeesFormatCompact.format(lastprice).toString()}",
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ]),
                  ],
                )),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: CircularPercentIndicator(
                animation: true,
                radius: 100,
                animateFromLastPercent: true,
                animationDuration: 1000,
                lineWidth: 25.0,
                backgroundColor: Colors.grey.shade200,
                reverse: reverse,
                progressColor: colorforindicator,
                percent: percent.abs() > 1.0 ? 1.0 : percent.abs(),
                center: Text(
                  "${(percent * 100).toStringAsFixed(2)}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
