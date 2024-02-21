import 'package:flutter/material.dart';
import 'package:CustomUpstox/Dividend/sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:CustomUpstox/api_data_models/smsmodal.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../Home.dart';

class Dividend extends StatefulWidget {
  const Dividend({super.key});

  @override
  State<Dividend> createState() => _DividendState();
}

class _DividendState extends State<Dividend> {
  List<smsmodal> message = [];
  num Totalreturn = 0;
  @override
  void initState() {
    checkpermission();
    super.initState();
  }

  void checkpermission() async {
    bool status = await Permission.sms.isGranted.then((value) {
      return value;
    });
    if (status) {
      message = await sms().getallsms().then((value) {
        return value;
      });
      if (mounted) {
        setState(() {
          this.message = message;
        });
      }
    } else {
      Permission.sms.request();
      checkpermission();
    }
    Totalreturn = message.fold(
        0, (previousValue, element) => previousValue + element.amount);
    if (mounted) {
      setState(() {
        Totalreturn = Totalreturn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    num ret = Totalreturn;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dividends'),
          backgroundColor: Colors.deepPurple,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
          
        ),
        bottomSheet: CustomTotalDividend(TotalReturn: ret),
        body: message.isEmpty
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
                padding: const EdgeInsets.only(bottom: 65),
                itemCount: message.length,
                itemBuilder: (BuildContext context, index) {
                  bool bordlast = index == message.length - 1;
                  return Material(
                      child: InkWell(
                    child: messageView(
                        message: message[index], bordlast: bordlast),
                    onTap: () {
                      showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDatarowBottomsheet(
                              message: message[index],
                            );
                          },
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer);
                    },
                  ));
                }));
  }
}

class messageView extends StatefulWidget {
  const messageView({
    super.key,
    required this.message,
    required this.bordlast,
  });
  final smsmodal message;
  final bool bordlast;
  @override
  State<messageView> createState() => _messageViewState();
}

class _messageViewState extends State<messageView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        decoration: widget.bordlast
            ? const BoxDecoration(
                color: Colors.white24,
                border: Border(
                    bottom: BorderSide(width: 2, color: Colors.black),
                    top: BorderSide(width: 1, color: Colors.black)))
            : const BoxDecoration(
                color: Colors.white24,
                border: Border(top: BorderSide(width: 1, color: Colors.black))),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, top: 5),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  border:
                      Border(top: BorderSide(width: 1, color: Colors.black))),
              child: Text(
                widget.message.address,
                textAlign: TextAlign.left,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              children: [
                Column(children: [
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    child: Text(
                      widget.message.name,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, bottom: 5),
                    width: MediaQuery.of(context).size.width * 3 / 4,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.message.date,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ]),
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width / 4,
                  child: Text(
                    "${widget.message.amount}",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }
}

class CustomDatarowBottomsheet extends StatelessWidget {
  CustomDatarowBottomsheet({
    super.key,
    required this.message,
  });
  final smsmodal message;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Colors.white30,
            border: Border(top: BorderSide(width: 1, color: Colors.black))),
        child: Column(children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
                border:
                    Border(bottom: BorderSide(width: 2, color: Colors.black))),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 10,bottom: 10),
            child: Text(
              message.address,
              textAlign: TextAlign.justify,
              overflow: TextOverflow.clip,
              
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(right: 10, top: 5),
            child: Text(
              message.date,
              textAlign: TextAlign.left,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Text(
              message.body,
              textAlign: TextAlign.left,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          )
        ]));
  }
}

class CustomTotalDividend extends StatefulWidget {
  const CustomTotalDividend({super.key, required this.TotalReturn});
  final num TotalReturn;

  @override
  State<CustomTotalDividend> createState() => CustomTotalDividendState();
}

class CustomTotalDividendState extends State<CustomTotalDividend> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 65,
        child: Row(children: [
          Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black)),
              ),
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.centerLeft,
              child: const Text(
                "Total Return",
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 25),
              )),
          Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.black),
                    top: BorderSide(color: Colors.black)),
              ),
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ))
        ]));
  }
}
