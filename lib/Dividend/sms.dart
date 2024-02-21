import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import '../api_data_models/smsmodal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sms {
  SmsQuery query = new SmsQuery();
  Future<List<smsmodal>> getallsms() async {
    List<smsmodal> sortedmessage = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool firsttimelaunch = prefs.containsKey('allsmslist');
    if (!firsttimelaunch) {
      List<SmsMessage> message = await query.getAllSms.then((value) {
        return value;
      });

      for (int i = 0; i < message.length; i++) {
        if (message[i].address?.contains("SBI") ?? false) {
          SmsMessage m = message[i];
          String str = m.body ?? "";

          if (str.contains("NACH-")) {
            List<String> arr = str.split(" ");
            int start = arr.indexOf("NACH-");
            int end = arr.indexOf("on");
            arr = arr.sublist(start, end);
            String name = "";
            for (int i = 1; i < arr.length; i++) {
              if (arr[i] == "of") {
                break;
              }
              name += " " + arr[i];
            }
            num amount = num.parse(arr[arr.length - 1]);
            DateTime d = m.date ?? DateTime.now();
            String date = DateFormat('yyyy-MM-dd').format(d);
            smsmodal sms = smsmodal(date.toString(), amount,
                name.trim().toString(), m.address.toString(), str);
            sortedmessage.add(sms);
            String allsms = jsonEncode(sms);
            prefs.setString("allsmslist$i", allsms);
          }
        }
      }
      prefs.setInt("smssize", sortedmessage.length);
    } else {
      int len = prefs.getInt("smssize") ?? 0;
      for (int i = 0; i < len; i++) {
        String allsms = prefs.getString("allsmslist$i") ?? "";
        var s = jsonDecode(allsms);
        smsmodal mod = smsmodal.fromJson(s);
        sortedmessage.add(mod);
      }
    }
    return sortedmessage;
  }
}
