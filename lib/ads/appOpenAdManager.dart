// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/app_constants.dart';
import '../utils/globalVariables.dart';
import 'AdsVariable.dart';

/// Utility class that manages loading and showing app open ads.
class AppOpenAdManager {

  bool get isAdAvailable {
    return AdsVariable.appOpenAdInstance != null;
  }

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  /// Load an AppOpenAd.
  loadAd(addId) async {
    if(GlobalVariables.isPremiumUser){
      return;
    }
    await AppOpenAd.load(
      adUnitId: addId, //Platform.isAndroid ? AdsVariable.appOpenAds : AdsVariable.appOpenAdsIOS,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          AdsVariable.appOpenAdInstance = ad;
          log('${AdsVariable.appOpenAdInstance} appOpen loaded');
        },
        onAdFailedToLoad: (error) {
          showLog('AppOpenAd failed to load: $error');
        },
      ),
    );
  }



  /// Shows the ad, if one exists and is not already being shown.
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable(adId) async {
    if(GlobalVariables.isPremiumUser){
      return;
    }
    if (AdsVariable.appOpenAdInstance == null) {
      loadAd(adId);
      return;
    }
    if (!isAdAvailable) {
      loadAd(adId);
      showLog('Tried to show ad before available.');
      return;
    }
    if (AdsVariable.isShowingAd) {
      showLog('Tried to show ad while already showing an ad.');
      return;
    }
    // if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
    //   loadAd(adId);
    //   showLog('Maximum cache duration exceeded. Loading another ad.');
    //   return;
    // }
    AdsVariable.appOpenAdInstance!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdsVariable.isShowingAd = true;
        showLog('$ad onAdShowedFullScreenContent');
        log("FullScreenContentCallback");
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Get.back();
        showLog('$ad onAdFailedToShowFullScreenContent: $error');
        AdsVariable.isShowingAd = false;
        ad.dispose();
        AdsVariable.appOpenAdInstance = null;
        loadAd(adId);

        /// ad loaded function hear after testing
      },
      onAdDismissedFullScreenContent: (ad) {
        Get.back();
        showLog('$ad onAdDismissedFullScreenContent');
        AdsVariable.isShowingAd = false;
        ad.dispose();
        AdsVariable.appOpenAdInstance = null;
        loadAd(adId);
      },
    );
    Get.to(() => EmptyScreen());
    await AdsVariable.appOpenAdInstance!.show();
  }
}


class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(backgroundColor: Colors.black,));
  }
}
