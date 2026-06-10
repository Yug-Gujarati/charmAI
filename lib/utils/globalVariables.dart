import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class AppData {
  static final AppData _appData = AppData._internal();

  bool entitlementIsActive = false;
  String appUserID = '';

  factory AppData() {
    return _appData;
  }

  AppData._internal();
}

final appData = AppData();

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}


class GlobalVariables {
  static bool isPremiumUser = false;
  static Future<bool> isInternetConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }


  static Map<String, Package>? availablePackages;
  static Package? selectedPackage;

  static String languageCode = '';
  static String tempLanguageCode = '';
  GlobalVariables();

}
