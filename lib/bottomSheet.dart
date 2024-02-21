import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:CustomUpstox/Home.dart';
import 'package:CustomUpstox/api_data_models/buysell.dart';

class bottomSheet extends StatefulWidget {
  bottomSheet(
      {super.key,
      required this.index,
      required this.bslist,
      this.financialYear,
      this.TotalBuy,
      this.TotalSell,
      this.TotalCharges});
  final index;
  final financialYear;
  final TotalBuy;
  final TotalSell;
  final TotalCharges;
  final List<buySell> bslist;

  @override
  State<bottomSheet> createState() => _bottomSheetState();
}

class _bottomSheetState extends State<bottomSheet> {
  @override
  Widget build(BuildContext context) {
    num TotalReturn = widget.TotalSell - widget.TotalBuy - widget.TotalCharges;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            centerTitle: true,
            title: Text(
                "Financial Year : ${widget.financialYear.substring(0, 2)}-${widget.financialYear.substring(2)}"),
            backgroundColor: Colors.deepPurple,
            iconTheme:const IconThemeData(
            color: Colors.white,
          ),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
        ),
        body: widget.bslist.isEmpty
            ? Center(
                child: DefaultTextStyle(
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText("Nothing To Show!!!"),
                    ],
                    repeatForever: true,
                    isRepeatingAnimation: true,
                  ),
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: widget.bslist.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == widget.bslist.length)
                    return CustomDataBottomsheetrow(
                      Totalbuy: widget.TotalBuy,
                      Totalsell: widget.TotalSell,
                      Totalcharges: widget.TotalCharges,
                      TotalReturn: TotalReturn,
                    );
                  return CustomDatarowBottomsheet(bsobj: widget.bslist[index]);
                }));
  }
}

class CustomDatarowBottomsheet extends StatelessWidget {
  CustomDatarowBottomsheet({
    super.key,
    required this.bsobj,
  });
  final buySell bsobj;

  Color colorcheck(num temp) {
    if (temp > 0) {
      return Colors.green;
    } else if (temp == 0) {
      return Colors.white30;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    num profitLoss = NetPLCalculateforbottomSheet().Netplcalculate(bsobj);
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.white30,
            border: Border(top: BorderSide(width: 1, color: Colors.black))),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black))),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "Scrip Name : ${bsobj.scripName}",
                textAlign: TextAlign.left,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(children: [
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "Trade Type : ${bsobj.tradeType}",
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "Quantity : ${bsobj.quantity}",
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              )
            ]),
            Row(children: [
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "Buy Date : ${bsobj.buyDate}",
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  bsobj.buyAverage < 99999
                      ? "Buy Avg : ${currencyconverter().indianRupeesFormat.format(bsobj.buyAverage).toString()}"
                      : "Buy Avg : ${currencyconverter().indianRupeesFormatCompact.format(bsobj.buyAverage).toString()}",
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            Row(children: [
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "Sell Date : ${bsobj.sellDate}",
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width / 2,
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  bsobj.sellAverage < 99999
                      ? "Sell Avg : ${currencyconverter().indianRupeesFormat.format(bsobj.sellAverage).toString()}"
                      : "Sell Avg : ${currencyconverter().indianRupeesFormatCompact.format(bsobj.sellAverage).toString()}",
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.topLeft,
                    child: const Text(
                      "Profit/Loss : ",
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.clip,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      profitLoss.abs() < 99999
                          ? currencyconverter()
                              .indianRupeesFormat
                              .format(profitLoss)
                              .toString()
                          : currencyconverter()
                              .indianRupeesFormatCompact
                              .format(profitLoss)
                              .toString(),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          color: colorcheck(profitLoss),
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class NetPLCalculateforbottomSheet {
  num Netplcalculate(buySell bs) {
    num totalreturn = (bs.sellAverage - bs.buyAverage) * bs.quantity;
    totalreturn = (totalreturn * 100).round() / 100.0;
    return totalreturn;
  }
  // num Totalwithlistcalculator(buySell bslist){

  // }
}

class CustomDataBottomsheetrow extends StatefulWidget {
  const CustomDataBottomsheetrow(
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
  State<CustomDataBottomsheetrow> createState() =>
      _CustomDataBottomsheetrowState();
}

class _CustomDataBottomsheetrowState extends State<CustomDataBottomsheetrow> {
  Color colorcheck(num temp) {
    if (temp > 0) {
      return Colors.green;
    } else if (temp == 0) {
      return Colors.white30;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
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
