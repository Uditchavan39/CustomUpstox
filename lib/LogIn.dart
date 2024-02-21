import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:CustomUpstox/main.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:CustomUpstox/secureStore.dart';
import 'package:CustomUpstox/auth/secrets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Authorization extends StatefulWidget {
  const Authorization({super.key});
  @override
  State<Authorization> createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  late WebViewController controller;
  bool isloading = true;
  @override
  void initState() {
    connectivitycheck();
    super.initState();
  }

  void connectivitycheck() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      control();
    } else {
      // ignore: use_build_context_synchronously
      showAlertDialog(context);
    }
  }

  void control() {
    controller = WebViewController()
      ..loadRequest(authorizationEndpoint)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) {
          const LinearProgressIndicator(
            backgroundColor: Colors.white,
          );
        },
        onPageFinished: (url) {
          setState(() {
            isloading = false;
          });
        },
        onNavigationRequest: (request) {
          if (request.url.startsWith(secrets().redirectUri.toString())) {
            Uri uro = Uri.parse(request.url.toString());
            codec = uro.query.toString().split("=")[1];
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AccessToken(code: codec)));
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));
  }

  final authorizationEndpoint =
      Uri.parse('https://api.upstox.com/v2/login/authorization/dialog')
          .replace(queryParameters: {
    'response_type': 'code',
    'client_id': secrets().apiKey,
    'redirect_uri': secrets().redirectUri,
  });
  late String codec;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                "Upstox LogIn",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              backgroundColor: Colors.deepPurple,
              titleTextStyle: const TextStyle(
                
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            body: isloading
                ? const LinearProgressIndicator()
                : WebViewWidget(controller: controller)));
  }
}
//---------------------------------------------------------------------------------

class AccessToken extends StatefulWidget {
  const AccessToken({super.key, required this.code});
  final String code;

  @override
  State<AccessToken> createState() => _AccessTokenState();
}

class _AccessTokenState extends State<AccessToken> {
  late WebViewController controller;
  String token = "";
  String userName = "User Loading...";
  @override
  void initState() {
    access();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return token == ""
        ? const ProgressIndicatorExample()
        : const MyHomePage(title: "My Upstox");
  }

  late Map<String, dynamic> parsed;
  void access() async {
    final access_token =
        Uri.parse('https://api.upstox.com/v2/login/authorization/token')
            .replace(queryParameters: {
      'code': widget.code.toString(),
      'client_id': secrets().apiKey,
      'client_secret': secrets().apiSecret,
      'redirect_uri': secrets().redirectUri,
      'grant_type': 'authorization_code'
    });

    Future<http.Response?> register() async {
      http.Response? response;
      try {
        response = await http.post(access_token,
            headers: {
              HttpHeaders.acceptHeader: "application/json",
              HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
            },
            body: jsonEncode(''));
      } catch (e) {
        showAlertDialog(context);
      }
      return response;
    }

    http.Response? par = await register();
    parsed = jsonDecode(par!.body);
    settoken();
    setState(() {
      token = parsed["access_token"];
      userName = parsed["user_name"];
    });
  }

  void settoken() async {
    await secureStore().setToken(parsed["access_token"]);
  }
}

showAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Exit"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
      child: const Text("Retry"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const Authorization()));
      });

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Network Error"),
    content: const Text("Internet Connection Not Available"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class ProgressIndicatorExample extends StatefulWidget {
  const ProgressIndicatorExample({super.key});

  @override
  State<ProgressIndicatorExample> createState() =>
      _ProgressIndicatorExampleState();
}

class _ProgressIndicatorExampleState extends State<ProgressIndicatorExample>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 35),
            LinearProgressIndicator(
              value: controller.value,
              semanticsLabel: 'Linear progress indicator',
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
