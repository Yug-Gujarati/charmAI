// import 'package:agingwonder/model/language_model.dart';

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

/// Parses a human-readable error message from an ailabapi or Gemini API error response body.
/// Priority: error_detail.message → error_msg → error.message → fallback
String parseApiErrorMessage(String responseBody, {String fallback = 'Something went wrong, please try again.'}) {
  try {
    final data = jsonDecode(responseBody);
    // ailabapi structured error: { error_detail: { message: "..." } }
    final detailMsg = data['error_detail']?['message'];
    if (detailMsg != null && detailMsg.toString().isNotEmpty) return detailMsg.toString();
    // ailabapi top-level error_msg
    final errorMsg = data['error_msg'];
    if (errorMsg != null && errorMsg.toString().isNotEmpty) return errorMsg.toString();
    // Gemini API error: { error: { message: "..." } }
    final geminiMsg = data['error']?['message'];
    if (geminiMsg != null && geminiMsg.toString().isNotEmpty) return geminiMsg.toString();
  } catch (_) {}
  return fallback;
}

showLog(String msg) {
  if (kDebugMode) {
    debugPrint("LOG >> $msg");
  }
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
