// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:CustomUpstox/main.dart';
import 'package:CustomUpstox/secureStore.dart';
import 'package:CustomUpstox/LogIn.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splash_screen extends StatefulWidget {
  const splash_screen({super.key});

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {
  late bool access_token = false;
  bool date_match = false;
  @override
  void initState() {
    //secureStore().deleteall();
    checktokenexpiredornot();
    super.initState();
  }

  void checktokenexpiredornot() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storeddate = await secureStore().getDate();
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await SessionManager().destroy();
    prefs.clear();
    if (storeddate != null && storeddate != date) {
      await secureStore().setDate(date);
    } else {
      access_token = (await secureStore().checkkey("access_token"))!;
      
      date_match = true;
    }
    setState(() {
      access_token = access_token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (access_token && date_match)
            ? const MyHomePage(
                title: "Custom Upstox",
              )
            : const Authorization(),
    );
  }
}
