// import 'package:agingwonder/model/language_model.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// clearFocus() {
//   FocusManager.instance.primaryFocus?.unfocus();
// }
//
// List<String> jsonList = [];
// List<String> saveImageListPath = <String>[];
//
// const int maxFailedLoadAttempts = 3;
// const String textFamily = "Madani";

showToast(msg) {
  Fluttertoast.showToast(
    msg: msg,
  );
}

showLog(String msg) {
  debugPrint("LOG >> $msg");
}

Future<void> launchURL(url) async {
  Uri.parse(url);
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}

Future<bool> checkConnectivity() async {
  ConnectivityResult? connectivityResult =
      (await (Connectivity().checkConnectivity())) as ConnectivityResult?;
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  } else if (connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.ethernet) {
    return true;
  }
  return false;
}
