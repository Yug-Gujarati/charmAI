import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/app_constants.dart';
import '../utils/constant.dart';
import '../utils/globalVariables.dart';
import '../utils/store_config.dart';
import '../view_model/category_provider.dart';
import '../view_model/coin_managment.dart';
import 'AdsVariable.dart';
import 'ads_loading_util.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showLog("Background message: ${message.notification?.title}");
}

class AdsSplashUtils {
  late SharedPreferences prefs;

  getOnlineIds({
    required Function() preLoads,
    required Function() navigateScreen,
  }) async {
    showLog("In Get Ads");
    prefs = await SharedPreferences.getInstance();

    premiumInit();
    configureSDK();

    AdsVariable.getAdIdsFromLocal();

    try {
      if (await GlobalVariables.isInternetConnected()) {
        try {
          await Firebase.initializeApp(
            options: FirebaseOptions(
              apiKey: "AIzaSyD3GyK-1_1v8n5GDfuI-q1OLg7lR8-GA3U",
              appId: "1:529244970093:android:175b01d12ed10a077b3364",
              messagingSenderId: "XXX",
              projectId: "charmai-55e2b",
            ),
          ).then((value) {
            /// add this line to enable firebase crashlytics
            FlutterError.onError =
                FirebaseCrashlytics.instance.recordFlutterFatalError;
            showLog("Firebase Initialized");
          });
          final remoteConfig = FirebaseRemoteConfig.instance;
          await remoteConfig.setConfigSettings(
            RemoteConfigSettings(
              fetchTimeout: const Duration(minutes: 1),
              minimumFetchInterval: const Duration(minutes: 5),
            ),
          );

          FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler,
          );



          await remoteConfig.fetchAndActivate();
          showLog("Map is ${remoteConfig.getValue("charm_ai").asString()}");
          Map<String, dynamic> mapValues1 = jsonDecode(
            remoteConfig.getValue("charm_ai").asString(),
          );
         // showLog("map is $mapValues1");

          showLog("this is 1");

          AdsVariable.ca_splash_interstitialAd =
              mapValues1["ca_splash_interstitialAd"];
          AdsVariable.ca_pre_interstitialAd =
              mapValues1["ca_pre_interstitialAd"];
          AdsVariable.ca_normal_openAd = mapValues1["ca_normal_openAd"];
          AdsVariable.ca_language_nativeAd = mapValues1["ca_language_nativeAd"];
          AdsVariable.ca_full_nativeAd = mapValues1["ca_full_nativeAd"];
          AdsVariable.ca_rewardedAd = mapValues1["ca_rewardedAd"];
          showLog("this is 2");
          AdsVariable.ca_nativeBgColor = mapValues1["ca_nativeBgColor"];
          AdsVariable.ca_buttonTextColor = mapValues1["ca_buttonTextColor"];
          AdsVariable.ca_buttonBgColor_start =
              mapValues1["ca_buttonBgColor_start"];
          AdsVariable.ca_buttonBgColor_end = mapValues1["ca_buttonBgColor_end"];
          AdsVariable.ca_headlineTxtColor = mapValues1["ca_headlineTxtColor"];
          AdsVariable.ca_bodyTxtColor = mapValues1["ca_bodyTxtColor"];
          showLog("this is 3");
          AdsVariable.ca_facebookId = mapValues1["ca_facebookId"];
          AdsVariable.ca_facebookToken = mapValues1["ca_facebookToken"];

          AdsVariable.ca_showOpenAdInSplash =
              mapValues1["ca_showOpenAdInSplash"];
          //AdsVariable.showPreloadedAd = mapValues1["show_preloaded_ad"];

          showLog("this is 5");

          AdsVariable.ca_free_coin = mapValues1["ca_free_coin"];
          showLog("this is in splash util ${AdsVariable.ca_free_coin}");

          AdsVariable.ca_click = mapValues1["ca_click"];
          AdsVariable.ca_gemini_api_key = mapValues1["ca_gemini_api_key"];
          AdsVariable.ca_ai_lab_tool_api = mapValues1["ca_ai_lab_tool_api"];

          AdsVariable.ca_week_bonus_coin = mapValues1["ca_week_bonus_coin"];
          AdsVariable.ca_month_bonus_coin = mapValues1["ca_month_bonus_coin"];
          AdsVariable.ca_first_plan_coin = mapValues1["ca_first_plan_coin"];
          AdsVariable.ca_second_plan_coin = mapValues1["ca_second_plan_coin"];
          AdsVariable.ca_rewared_credit = mapValues1["ca_rewared_credit"];
          AdsVariable.ca_showRewardedAd_ai_lab_api = mapValues1["ca_showRewardedAd_ai_lab_api"];
          AdsVariable.ca_showRewaredAd_gemini_api = mapValues1["ca_showRewaredAd_gemini_api"];
          AdsVariable.ca_reduce_coin_on_ai_lab_api = mapValues1["ca_reduce_coin_on_ai_lab_api"];
          AdsVariable.ca_reduce_coin_on_gemini_api = mapValues1["ca_reduce_coin_on_gemini_api"];
          AdsVariable.ca_tester_email = mapValues1["ca_tester_email"];
          AdsVariable.ca_tester_password = mapValues1["ca_tester_password"];

          showLog("this is 4");
          AdsVariable.setAdIdsFromLocal();

          await fetchPurchase();

          setupFbAdsId();

          if (GlobalVariables.isPremiumUser) {
            Future.delayed(const Duration(seconds: 3), () {
              navigateScreen();
            });
            return;
          }

          ///LOAD AND SHOW OPEN OR SPLASH AD BASED ON CONDITION
          if (AdsVariable.ca_showOpenAdInSplash) {
            showLog("this is open ad show");
            AdsLoadUtil().loadAndShowOpenAdInSplash(
              navigateScreen,
              AdsVariable.ca_normal_openAd,
              preLoads,
            );
          } else {
            showLog("this is inter ad show");
            AdsLoadUtil().loadInterSplash(
              preLoads,
              navigateScreen,
              AdsVariable.ca_splash_interstitialAd,
            );
          }
        } on PlatformException catch (exception) {
          Future.delayed(Duration(seconds: 3), () {
            navigateScreen();
          });
          showLog("Exception is $exception");
        } catch (exception) {
          Future.delayed(Duration(seconds: 3), () {
            navigateScreen();
          });
          showLog("Exception is $exception");
        }
      } else {
        showLog("Not Connected");

        Future.delayed(Duration(seconds: 3), () {
          navigateScreen();
        });

        /// Facebook id setup
      }
    } catch (e) {
      showLog("$e");
      Future.delayed(Duration(seconds: 3), () {
        navigateScreen();
      });
    }
  }

  fetchPurchase() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      showLog("CUSTOMER INFO $customerInfo");
      if (customerInfo.entitlements.all[entitlementKey] != null &&
          customerInfo.entitlements.all[entitlementKey]!.isActive == true) {
        GlobalVariables.isPremiumUser = true;
        AdsVariable.resetAdIds();
      } else {
        GlobalVariables.isPremiumUser = false;
      }

      if (GlobalVariables.isPremiumUser) {
        showLog("Purchase ----->${GlobalVariables.isPremiumUser}");
        AdsVariable.resetAdIds();
      }
    } catch (e) {
      showLog("PURCHASE_ERROR >> ${e.toString()}");
    }
  }

  static void onShowAds(BuildContext context, Function onDismiss) {
    if (AdsVariable.ca_pre_interstitialAd == "11") {
      onDismiss();
      return;
    }
    try {
      if (AdsVariable.current_click % AdsVariable.ca_click == 0) {
        AdsLoadUtil.loadAndShowOnceInterstitial(
          adId: AdsVariable.ca_pre_interstitialAd,
          onDismissed: () {
            onDismiss();
          },
        );
      } else {
        onDismiss();
      }
    } catch (e) {
      showLog("ERROR is $e");
      onDismiss();
    }
    AdsVariable.current_click++;
  }

  Future<void> rewardCredit(BuildContext context, int rewaredCredit) async {
    if (!context.mounted) {
      showLog("Cannot give reward: Widget is deactivated.");
      return;
    }
    showLog("User earned reward: $rewaredCredit");

    try {
      final coinProvider = Provider.of<CoinProvider>(context, listen: false);
      coinProvider.incrementCoins(rewaredCredit);
      await context.read<CoinProvider>().fetchCoins();

      int currentCoins = context.read<CoinProvider>().coins;

      showLog("this is rewared after ad credits $currentCoins");
    } catch (e) {
      showLog("this is error in rewared given $e");
    }
  }
}

premiumInit() {
  if (Platform.isIOS || Platform.isMacOS) {
    StoreConfig(store: Store.appStore, apiKey: appleApiKey);
  } else if (Platform.isAndroid) {
    const useAmazon = bool.fromEnvironment("amazon");
    StoreConfig(
      store: useAmazon ? Store.amazon : Store.playStore,
      apiKey: useAmazon ? "amazonApiKey" : googleApiKey,
    );
  }
}

void setupFbAdsId() async {
  showLog("Call 1");
  const platformMethodChannel = MethodChannel('nativeChannel');
  showLog("Call 2");
  if (Platform.isIOS) {
    platformMethodChannel.invokeMethod('setToast', {
      'isPurchase': GlobalVariables.isPremiumUser.toString(),
      'facebookId': AdsVariable.ca_facebookId,
      'facebookToken': AdsVariable.ca_facebookToken,
      'nativeBGColor': AdsVariable.ca_nativeBgColor,
      'btnBgColor': AdsVariable.ca_buttonBgColor_start,
      'btnBgColor3': AdsVariable.ca_buttonBgColor_end,
      'btnTextColor': AdsVariable.ca_buttonTextColor,
      'headerTextColor': AdsVariable.ca_headlineTxtColor,
      'bodyTextColor': AdsVariable.ca_bodyTxtColor,
    });
  } else {
    platformMethodChannel.invokeMethod('setToast', {
      'fb_appid': AdsVariable.ca_facebookId,
      'fb_token': AdsVariable.ca_facebookToken,
      'btnBgColorG1': "#${AdsVariable.ca_buttonBgColor_start}",
      'btnBgColorG2': "#${AdsVariable.ca_buttonBgColor_end}",
      'nativeBGColor': "#${AdsVariable.ca_nativeBgColor}",
      'headerTextColor': "#${AdsVariable.ca_headlineTxtColor}",
      'bodyTextColor': "#${AdsVariable.ca_bodyTxtColor}",
      'btnTextColor': "#${AdsVariable.ca_buttonTextColor}",
    });
  }
  showLog("Call 3");
}

Future<void> configureSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);
  showLog('==========setLogLevel=============');
  PurchasesConfiguration configuration;
  if (StoreConfig.isForAmazonAppstore()) {
    configuration = AmazonConfiguration(StoreConfig.instance.apiKey);
  } else {
    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey);
  }
  configuration.entitlementVerificationMode =
      EntitlementVerificationMode.informational;
  await Purchases.configure(configuration);
  await Purchases.enableAdServicesAttributionTokenCollection();
}

Future<FormError?> initializeGDPR() async {
  final completer = Completer<FormError?>();
  final params = ConsentRequestParameters(
    // consentDebugSettings: ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea, testIdentifiers: ['1D1F38988F68A750C4E81465BAA4D7FB']),
  );
  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      if (await isPrivacyOptionsStatus()) {
        await loadConsentForm();
      } else {
        await initializeWithOutGDPR();
      }
      completer.complete();
    },
    (error) {
      completer.complete(error);
    },
  );

  return completer.future;
}

Future<TrackingStatus> initializeWithOutGDPR() async {
  final completer = Completer<TrackingStatus>();
  AppTrackingTransparency.requestTrackingAuthorization().then((value) async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.authorized) {
      showLog("GDPR: TrackingStatus.required");
      await initializeMobileAds();
      completer.complete(TrackingStatus.authorized);
    } else {
      showLog("GDPR: TrackingStatus Not Required");
      await initializeMobileAds();
      completer.complete(TrackingStatus.denied);
    }
  });
  return completer.future;
}

void showPrivacyOptionsForm(
  OnConsentFormDismissedListener onConsentFormDismissedListener,
) {
  ConsentForm.showPrivacyOptionsForm(onConsentFormDismissedListener);
}

Future<FormError?> loadConsentForm() async {
  final completer = Completer<FormError?>();

  ConsentForm.loadConsentForm(
    (consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((formError) {
          completer.complete(loadConsentForm());
        });
      } else {
        await initializeMobileAds();
        completer.complete();
      }
    },
    (FormError? error) {
      completer.complete(error);
    },
  );

  return completer.future;
}

Future<void> initializeMobileAds() async {
  if (await isPrivacyOptionsStatus()) {
    AdsVariable.isPrivacyOptionsRequired = true;
  } else {
    AdsVariable.isPrivacyOptionsRequired = false;
  }
  await MobileAds.instance.initialize();
}

Future<bool> isPrivacyOptionsStatus() async {
  return await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;
}

