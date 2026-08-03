// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/app_constants.dart';
import '../utils/globalVariables.dart';
import 'AdsVariable.dart';
import 'ads_loading_util.dart';
import 'appOpenAdManager.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges({bool shouldShow = true}) {
    showLog("AppLifecycleReactor Listen Called");
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) {
      showLog("AppLifecycleReactor Should Show $shouldShow");
      showLog("State is $state");
      if (shouldShow && !GlobalVariables.isPremiumUser) {
        onAppStateChanged(state);
      } else {
        showLog("NOT SHOW");
      }
    });
  }

  void onAppStateChanged(AppState appState) {
    showLog("In ON APP STATE CHANGED");
    if (appState == AppState.foreground) {
      showLog("App State :- $appState");
      showLog('FOREGROUND');

      // appOpenAdManager.showAdIfAvailable(AdsVariable.appOpenAd);
      AdsLoadUtil().loadAndShowOpenAd(AdsVariable.ca_normal_openAd);
    } else if (appState == AppState.background) {
      showLog(AdsVariable.ca_normal_openAd);
      ///TODO: CHANGES
      showLog('BACKGROUND');

      ///When App Go In Background If Ad is not available then it will load open Ad
      // if (!AppOpenAdManager().isAdAvailable) {
      //   showLog("AD NOT AVAILABLE");
      //   AdsLoadUtil().loadAppOpenAd();
      // }
    }
  }
}
