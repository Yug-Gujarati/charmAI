import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import '../utils/custom_text.dart';
import '../utils/globalVariables.dart';
import 'AdsVariable.dart';
import 'AppLifeReactor.dart';
import 'ads_init_utils.dart';
import 'ads_loading_screen.dart';
import 'ads_shimmer_utils.dart';
import 'appOpenAdManager.dart';
import 'open_screen_loading_screen.dart';

class AdsLoadUtil extends GetxController {
  late SharedPreferences prefs;
  late AppLifecycleReactor appLifecycleReactor;

  ///-----------_FOR BANNER AD IMPLEMENTATION ------------------------------------
  ///REFER: FILE NAMED: ads_banner_utils.dart or intro screen

  loadAppOpenAd() async {
    showLog("Load from BG...");
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()
      ..loadAd(AdsVariable.ca_normal_openAd);
    appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
    );
    AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
    ).listenToAppStateChanges();
  }

  ///---------- load and show open ad in splash
  void loadAndShowOpenAdInSplash(
    Function onDismissed,
    String adId,
    Function loadPreLoadAds,
  ) {
    AdsVariable.isShowingAd = true;
    AppOpenAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) async {
          await loadPreLoadAds();
          print(
            "Ad Loaded:=====================================================================",
          );
          ad.show();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('Ad showed full screen content');
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('$ad onAdFailedToShowFullScreenContent=======:- $error');
              AdsVariable.isShowingAd = false;

              Future.delayed(const Duration(seconds: 3), () {
                //Navigator.of(context).pop();
                onDismissed();
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              onDismissed();

              AdsVariable.isShowingAd = false;

              ///CHANGES TO LOAD PRE LOAD AFTER SPLASH DISMISSED

              AppOpenAdManager appOpenAdManager = AppOpenAdManager();
              AppLifecycleReactor lifecycleReactor = AppLifecycleReactor(
                appOpenAdManager: appOpenAdManager,
              );
              lifecycleReactor.listenToAppStateChanges(shouldShow: true);
              print('$ad onAdDismissedFullScreenContent========:-');
            },
          );
        },
        onAdFailedToLoad: (error) {
          AdsVariable.isShowingAd = false;

          Future.delayed(const Duration(seconds: 3), () {
            onDismissed();
          });
          print(
            "Ad Not Loaded:=====================================================================",
          );
          print(error);
        },
      ),
    );
  }

  void loadAndShowOpenAd(String adId) {
    openAdOpenAdLoadingScreen.show();
    AdsVariable.isShowingAd = true;

    try {
      AppOpenAd.load(
        adUnitId: adId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) async {
            print(
              "Ad Loaded:=====================================================================",
            );
            ad.show();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                openAdOpenAdLoadingScreen.hide();
                print('Ad showed full screen content');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('$ad onAdFailedToShowFullScreenContent=======:- $error');
                openAdOpenAdLoadingScreen.hide();
                AdsVariable.isShowingAd = false;
              },
              onAdDismissedFullScreenContent: (ad) {
                ///CHANGES TO LOAD PRE LOAD AFTER SPLASH DISMISSED
                AdsVariable.isShowingAd = false;

                AppOpenAdManager appOpenAdManager = AppOpenAdManager();
                AppLifecycleReactor lifecycleReactor = AppLifecycleReactor(
                  appOpenAdManager: appOpenAdManager,
                );
                lifecycleReactor.listenToAppStateChanges(shouldShow: true);
                print('$ad onAdDismissedFullScreenContent========:-');
              },
            );
          },
          onAdFailedToLoad: (error) {
            AdsVariable.isShowingAd = false;

            openAdOpenAdLoadingScreen.hide();
            print(
              "Ad Not Loaded:=====================================================================",
            );
            print(error);
          },
        ),
      );
    } catch (e) {
      openAdOpenAdLoadingScreen.hide();
      AdsVariable.isShowingAd = false;
      print("ERROR IN LOAD AND SHOW OPEN AD $e");
    }
  }

  /// ------- Load Common Inter (Mine) -----------------------------
  static InterstitialAd? _interstitialAd;
  static String interstitialId = "";
  static bool isAdLoaded = false;

  static loadPreInterstitialAd({required String adId}) {
    interstitialId = adId;
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }
    try {
      InterstitialAd.load(
        adUnitId: adId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            isAdLoaded = true;
            showLog("Pre Inter Loaded");
          },
          onAdFailedToLoad: (error) {
            isAdLoaded = false;
            showLog("Pre Inter Failed $error");
          },
        ),
      );
    } catch (e) {
      print("ERROR IN LOAD PRE INTERSTITIAL AD $e");
    }
  }

  static void showInterstitial({required Function onDismissed}) {
    if (GlobalVariables.isPremiumUser) {
      onDismissed();
      return;
    }
    AdsVariable.isShowingAd = true;

    if (isAdLoaded && _interstitialAd != null) {
      showLog("IT IS PRE LOADED");
      loadingScreen.show();
      // Delay showing the ad for 1500 milliseconds
      Future.delayed(const Duration(milliseconds: 500), () {
        loadingScreen.hide();
        // Close the loading dialog

        // Show the ad
        _interstitialAd!.show();
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdImpression: (ad) {
            showLog("onAdImpression---> true");
            Future.delayed(const Duration(milliseconds: 500), () {
              onDismissed();
            });
          },
          onAdDismissedFullScreenContent: (ad) {
            showLog("onAdDismissedFullScreenContent---> true");
            AdsVariable.isShowingAd = false;

            ad.dispose();
            _interstitialAd!.dispose().then(
              (value) => loadPreInterstitialAd(adId: interstitialId),
            );
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            AdsVariable.isShowingAd = false;

            showLog("onAdFailedToShowFullScreenContent---> Error $error");
            ad.dispose();
            // _interstitialAd!.dispose().then((value) => loadPreInterstitialAd(adId: interstitialId));
            loadPreInterstitialAd(adId: interstitialId);
            onDismissed();
          },
        );
      });
    } else {
      loadAndShowPreloadedInterstitial(
        adId: AdsVariable.ca_pre_interstitialAd,
        onDismissed: onDismissed,
      );
    }
  }

  /// ------ Splash screen inter load & show --------------------------------------------
  InterstitialAd? splashInterAd;
  InterstitialAd? rewardReplacementAd;

  loadInterSplash(
    Function() loadPreLoadAds,
    Function() navigateScreen,
    String adUnitId,
  ) async {
    prefs = await SharedPreferences.getInstance();
    showLog('>> SHOW INTER CALL <<');
    print('>> SHOW INTER CALL <<');
    showLog(
      'AdsVariable.appOpenSplashIOS >>${AdsVariable.ca_pre_interstitialAd}',
    );

    if (!GlobalVariables.isPremiumUser) {
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) async {
            print("AD LOADED");

            splashInterAd = ad;
            splashInterAd!.show();

            ///CHANGES IT FROM onAdShowedFullScreenContent To onAdLoaded
            //TODO: CHANGES
            await loadPreLoadAds();

            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) async {
                showLog("onAdShowedFullScreenContent loadInterSplash");
                print("onAdShowedFullScreenContent loadInterSplash");
              },
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) async {
                showLog("onAdImpression loadInterSplash");
                print("onAdImpression loadInterSplash");
                Future.delayed(const Duration(milliseconds: 500)).then((value) {
                  navigateScreen();
                });
              },

              // Called when the ad failed to show full screen content.
              //
              onAdFailedToShowFullScreenContent: (ad, err) async {
                // Dispose the ad here to free resources.
                ad.dispose();

                showLog("onAdFailedToShowFullScreenContent loadInterSplash");
                print("onAdFailedToShowFullScreenContent loadInterSplash");
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) async {
                // Dispose the ad here to free resources.\
                AppOpenAdManager appOpenAdManager = AppOpenAdManager();
                AppLifecycleReactor lifecycleReactor = AppLifecycleReactor(
                  appOpenAdManager: appOpenAdManager,
                );
                lifecycleReactor.listenToAppStateChanges(shouldShow: true);
                ad.dispose();
                showLog("onAdDismissedFullScreenContent loadInterSplash");
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {
                showLog("onAdClicked loadInterSplash");
              },
            );

            showLog('$ad loaded.loadInterSplash ');
            // Keep a reference to the ad so you can show it later.
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) async {
            showLog('InterstitialAd failed to load loadInterSplash: $error');
            print('InterstitialAd failed to load loadInterSplash: $error');
            await loadPreLoadAds();
            Future.delayed(Duration(seconds: 3), () {
              navigateScreen();
            });
          },
        ),
      );
    }
  }

  static void loadAndShowPreloadedInterstitial({
    required String adId,
    required Function onDismissed,
  }) {
    showLog("IT IS LOAD AND SHOW");
    isAdLoaded = false;
    loadingScreen.show();

    if (_interstitialAd != null) {
      showInterstitial(onDismissed: onDismissed);
    } else {
      interstitialId = adId;
      if (_interstitialAd != null) {
        _interstitialAd!.dispose();
      }
      AdsVariable.isShowingAd = true;

      try {
        InterstitialAd.load(
          adUnitId: adId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              _interstitialAd = ad;
              loadingScreen.hide();
              _interstitialAd!.show();
              _interstitialAd!.fullScreenContentCallback =
                  FullScreenContentCallback(
                    onAdImpression: (ad) {
                      Future.delayed(Duration(seconds: 1), () {
                        onDismissed();
                      });
                    },
                    onAdDismissedFullScreenContent: (ad) {
                      ad.dispose();
                      print("Ad Reloaded");
                      AdsVariable.isShowingAd = false;
                      loadPreInterstitialAd(
                        adId: AdsVariable.ca_pre_interstitialAd,
                      );
                    },
                    onAdFailedToShowFullScreenContent: (ad, error) {
                      AdsVariable.isShowingAd = false;

                      ad.dispose();
                      print("Ad Reloaded");
                      loadPreInterstitialAd(
                        adId: AdsVariable.ca_pre_interstitialAd,
                      );
                      onDismissed();
                    },
                  );
            },
            onAdFailedToLoad: (error) {
              AdsVariable.isShowingAd = false;

              loadingScreen.hide();
              onDismissed();
            },
          ),
        );
      } catch (e) {
        loadingScreen.hide();
        AdsVariable.isShowingAd = false;
        print("ERROR IN LOAD AND SHOW $e");
      }
    }
  }

  static void loadAndShowOnceInterstitial({
    required String adId,
    required Function onDismissed,
  }) {
    showLog("IT IS LOAD AND SHOW INTER ONCE");
    isAdLoaded = false;
    loadingScreen.show();
    AdsVariable.isShowingAd = true;

    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          loadingScreen.hide();
          ad.show();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdImpression: (ad) {
              Future.delayed(Duration(seconds: 1), () {
                onDismissed();
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              AdsVariable.isShowingAd = false;

              print("Ad Reloaded");
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              AdsVariable.isShowingAd = false;

              print("Ad Reloaded");

              onDismissed();
            },
          );
        },
        onAdFailedToLoad: (error) {
          AdsVariable.isShowingAd = false;

          loadingScreen.hide();
          onDismissed();
        },
      ),
    );
  }

  ///REWARDED ADS
  // static RewardedAd? _rewardedAd;
  // static String rewardedId = "";
  // static bool isRewardedLoaded = false;
  //
  // static void loadRewardedAd(
  //     {required Function onAdLoaded, required Function(AdError) onAdFailed, required String adId}) {
  //   rewardedId = adId;
  //
  //   RewardedAd.load(
  //     adUnitId: adId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
  //       _rewardedAd = ad;
  //       isRewardedLoaded = true;
  //       onAdLoaded();
  //     }, onAdFailedToLoad: (e) {
  //       onAdFailed(e);
  //     }),
  //   );
  // }

  static void loadAndShowRewardedAdOnce({
    required BuildContext context,
    required String adId,
    required Function onDismissed,
    required Function(int rewardCredit) onRewarded,
  }) async {
    showLog("LOAD AND SHOW REWARD ONCE");
    if (!context.mounted) return;
    loadingScreen.show();
    AdsVariable.isShowingAd = true;

    try {
      await RewardedAd.load(
        adUnitId: adId,
        request: const AdRequest(),

        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            loadingScreen.hide();
            AdsVariable.isShowingAd = false;
            ad.show(
              onUserEarnedReward: (AdWithoutView adView, RewardItem reward) {
                //onDismissed();

                showLog("this is on rewared ad show method");
                showLog("rewared credits ${AdsVariable.ca_rewared_credit}");
                onRewarded(AdsVariable.ca_rewared_credit);
              },
            );

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdImpression: (ad) {
                // Optionally handle ad impression
                showLog("Rewarded onAdImpression---> true");
              },
              onAdDismissedFullScreenContent: (ad) {
                showLog("Rewarded onAdDismissedFullScreenContent---> true");
                AdsVariable.isShowingAd = false;
                ad.dispose();
                Future.delayed(const Duration(milliseconds: 1000), () {
                  onDismissed();
                });
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                // Handle failure to show the ad
                showLog(
                  "Rewarded onAdFailedToShowFullScreenContent---> Error $error",
                );
                AdsVariable.isShowingAd = false;

                //loadingScreen.hide();
                showLog('Failed to load rewarded ad: $error');
                Fluttertoast.showToast(
                  msg: "Failed to show ad. Please try again later.",
                );
                ad.dispose();
                onDismissed();
              },
            );
          },

          onAdFailedToLoad: (e) {
            // loadingScreen.hide();

            AdsVariable.isShowingAd = false;

            Fluttertoast.showToast(
              msg:
                  "Rewarded ads are currently unavailable. Please try again later.",
            );
            loadingScreen.hide();
            onDismissed();

          },
        ),
      );
    } catch (e) {
      //loadingScreen.hide();
      Fluttertoast.showToast(
        msg: "An error occurred while loading ads. Please try again later.",
      );
      loadingScreen.hide();
      onDismissed();

    }
  }

  /// lanhuage native ad yug
  static NativeAd? nativeAd;
  static RxBool isNativeAdLoaded = false.obs;
  static RxBool isNativeAdFailed = false.obs;

  Future<NativeAd> loadNative(String adUnitId, bool isSmallNative) async {
    showLog("isSmallNativefirst--->$isSmallNative");

    isNativeAdLoaded.value = false;
    nativeAd = NativeAd(
      adUnitId: adUnitId.toString(),
      factoryId: isSmallNative ? 'smallNativeAds' : 'bigNativeAds',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          nativeAd = ad as NativeAd?;
          isNativeAdLoaded.value = true;
          showLog('isLoaded loadNative');
        },
        onAdFailedToLoad: (ad, error) {
          showLog('onAdFailedToLoad loadNative');
          nativeAd!.dispose();
          nativeAd = null;
          isNativeAdLoaded.value = false;
          isNativeAdFailed.value = true;
        },
      ),
      request: const AdRequest(),
    );
    try {
      await nativeAd!.load();
    } catch (e) {
      print("ERROR IN LOAD NATIVE AD $e");
      nativeAd!.dispose();
      nativeAd = null;
      isNativeAdLoaded.value = false;
      isNativeAdFailed.value = true;
    }
    return nativeAd!;
  }

  // /// lanhuage native ad yug
  // static NativeAd? secondNativeAd;
  // static RxBool isSecondNativeAdLoaded = false.obs;
  // static RxBool isSecondNativeAdFailed = false.obs;
  //
  // Future<NativeAd> loadSecondNative(String adUnitId, bool isSmallNative) async {
  //   showLog("isSmallNativesecond--->$isSmallNative");
  //   isSecondNativeAdLoaded.value = false;
  //   secondNativeAd = NativeAd(
  //     adUnitId: adUnitId.toString(),
  //     factoryId: isSmallNative ? 'smallNativeAds' : 'bigNativeAds',
  //     listener: NativeAdListener(
  //       onAdLoaded: (ad) {
  //         secondNativeAd = ad as NativeAd?;
  //         isSecondNativeAdLoaded.value = true;
  //         showLog('isLoaded SeondloadNative');
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         showLog('onAdFailedToLoad SeondloadNative');
  //         secondNativeAd!.dispose();
  //         isSecondNativeAdLoaded.value = false;
  //         isSecondNativeAdFailed.value = true;
  //       },
  //     ),
  //     request: const AdRequest(),
  //   );
  //   try {
  //     await secondNativeAd!.load();
  //   } catch (e) {
  //     print("ERROR IN LOAD NATIVE AD $e");
  //     secondNativeAd!.dispose();
  //     secondNativeAd = null;
  //     isSecondNativeAdLoaded.value = false;
  //     isSecondNativeAdFailed.value = true;
  //   }
  //   return secondNativeAd!;
  // }

  /// intro native ad yug

  static NativeAd? nativeIntroAd;
  static RxBool isNativeIntroAdLoaded = false.obs;
  static RxBool isNativeIntroAdFailed = false.obs;

  Future<NativeAd> loadIntroNative(String adUnitId, bool isSmallNative) async {
    showLog("isSmallNativeintro--->$isSmallNative");
    isNativeIntroAdLoaded.value = false;
    nativeIntroAd = null;
    if (nativeIntroAd == null) {
      nativeIntroAd = NativeAd(
        adUnitId: adUnitId.toString(),
        factoryId: 'fullNativeAds',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            nativeIntroAd = ad as NativeAd?;
            isNativeIntroAdLoaded.value = true;
            showLog('isLoaded INTRO loadNative');
          },
          onAdFailedToLoad: (ad, error) {
            showLog('onAdFailedToLoad INTRO loadNative $error');
            nativeIntroAd!.dispose();
            isNativeIntroAdLoaded.value = false;
            isNativeIntroAdFailed.value = true;
          },
        ),
        request: const AdRequest(),
      );
      await nativeIntroAd!.load();
      return nativeIntroAd!;
    } else {
      showLog("this is native ad failed ${isNativeIntroAdFailed.value}");
      print("outtttt");
      return nativeIntroAd!;
    }
    // try {
    //   await nativeIntroAd!.load();
    // } catch (e) {
    //   print("ERROR IN LOAD NATIVE AD $e");
    //   nativeIntroAd!.dispose();
    //   nativeIntroAd = null;
    //   isNativeIntroAdLoaded.value = false;
    //   isNativeIntroAdFailed.value = true;
    // }
    return nativeIntroAd!;
  }

  /// home native ad yug
  static NativeAd? homeNativeAd;
  static RxBool ishomeNativeAdLoaded = false.obs;
  static RxBool ishomeNativeAdFailed = false.obs;

  Future<NativeAd> loadHomeNative(String adUnitId, bool isSmallNative) async {
    showLog("isSmallhomeNativesecond--->$isSmallNative");
    showLog("home native ad load");
    ishomeNativeAdLoaded.value = false;
    homeNativeAd = NativeAd(
      adUnitId: adUnitId.toString(),
      factoryId: isSmallNative ? 'smallNativeAds' : 'bigNativeAds',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          homeNativeAd = ad as NativeAd?;
          ishomeNativeAdLoaded.value = true;
          showLog('isLoaded HomeloadNative');
        },
        onAdFailedToLoad: (ad, error) {
          showLog('onAdFailedToLoad HomeloadNative');
          homeNativeAd!.dispose();
          homeNativeAd = null;
          ishomeNativeAdLoaded.value = false;
          ishomeNativeAdFailed.value = true;
        },
      ),
      request: const AdRequest(),
    );
    try {
      await homeNativeAd!.load();
    } catch (e) {
      print("ERROR IN LOAD NATIVE AD $e");
      homeNativeAd!.dispose();
      homeNativeAd = null;
      ishomeNativeAdLoaded.value = false;
      ishomeNativeAdFailed.value = true;
    }
    return homeNativeAd!;
  }
}

/// Native ads
class NativeAdsWidget extends StatefulWidget {
  final bool isSmallNative;
  final NativeAd? showNativeAd;
  final double? height;

  const NativeAdsWidget({
    super.key,
    required this.showNativeAd,
    required this.isSmallNative,
    this.height,
  });

  @override
  State<NativeAdsWidget> createState() => _NativeAdsWidgetState();
}

/// Native ads
class _NativeAdsWidgetState extends State<NativeAdsWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    showLog("CHECK NULL >> ${AdsLoadUtil.isNativeAdLoaded.value}");
    return Obx(
      () => AdsLoadUtil.isNativeAdLoaded.value && widget.showNativeAd != null
          ? StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  margin: EdgeInsets.only(bottom: 40.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: Colors.transparent,
                  ),
                  padding: EdgeInsets.only(bottom: 10.w, top: 0.w),
                  width: 1080.w,
                  height: widget.isSmallNative ? 150 : 300,
                  child: AdWidget(ad: widget.showNativeAd!),
                );
              },
            )
          : getShimmerWidget(),
    );
  }

  Widget getShimmerWidget() {
    if (AdsLoadUtil.isNativeAdFailed.value) {
      return Container(height: 0);
    } else {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 50.w, vertical: 20.h),

        child: widget.isSmallNative ? ShimmerSmallNative() : ShimmerBigNative(),
      );
    }
  }
}

/// second native ads
// class SecondNativeAdsWidget extends StatefulWidget {
//   final bool isSecondSmallNative;
//   final NativeAd? showSecondNativeAd;
//   final double? Secondheight;
//
//   const SecondNativeAdsWidget(
//       {super.key, required this.showSecondNativeAd, required this.isSecondSmallNative, this.Secondheight});
//
//   @override
//   State<SecondNativeAdsWidget> createState() => _SecondNativeAdsWidgetState();
// }

// /// Native ads
// class _SecondNativeAdsWidgetState extends State<SecondNativeAdsWidget> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     showLog("CHECK NULL >> ${AdsLoadUtil.isSecondNativeAdLoaded.value}");
//     return Obx(() => AdsLoadUtil.isSecondNativeAdLoaded.value && widget.showSecondNativeAd != null
//         ? StatefulBuilder(builder: (context, setState) {
//       return Container(
//         margin: EdgeInsets.only(bottom: 40.h),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5.w),
//           color: Colors.transparent,
//         ),
//         padding: EdgeInsets.only(bottom: 10.w, top: 0.w),
//         width: 1080.w,
//         height: widget.isSecondSmallNative ? 150 : 300,
//         child: AdWidget(ad: widget.showSecondNativeAd!),
//       );
//     })
//         : getShimmerWidget());
//   }
//
//   Widget getShimmerWidget() {
//     if (AdsLoadUtil.isSecondNativeAdFailed.value) {
//       return Container(
//         height: 0,
//       );
//     } else {
//       return Container(
//           margin: EdgeInsets.symmetric(horizontal: 50.w,vertical: 20.h),
//
//           child: widget.isSecondSmallNative ? ShimmerSmallNative() : ShimmerBigNative());
//     }
//   }
// }

class NativeIntroAdsWidget extends StatefulWidget {
  final NativeAd? showNativeAd;

  const NativeIntroAdsWidget({super.key, required this.showNativeAd});

  @override
  State<NativeIntroAdsWidget> createState() => _NativeIntroAdsWidgetState();
}

/// Native ads
class _NativeIntroAdsWidgetState extends State<NativeIntroAdsWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    showLog("CHECK NULL >> ${AdsLoadUtil.isNativeIntroAdLoaded.value}");
    return Obx(
      () =>
          AdsLoadUtil.isNativeIntroAdLoaded.value && widget.showNativeAd != null
          ? StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  margin: EdgeInsets.only(top: 20.h, bottom: 150.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: Colors.transparent,
                  ),
                  width: 1080.w,
                  height: Get.height,
                  child: AdWidget(ad: widget.showNativeAd!),
                );
              },
            )
          : getShimmerWidget(),
    );
  }

  Widget getShimmerWidget() {
    if (AdsLoadUtil.isNativeIntroAdFailed.value) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, color: Colors.white, size: 300.sp),
              SizedBox(height: 50.h),

              CustomText(
                text: "Failed to load this content",
                fontSize: 50.sp,
                fontFamily: 'bold',
                textColor: Colors.white,
                maxline: 1,
                width: 600.w,
              ),
            ],
          ),
        ),
      );
    } else {
      return ShimmerFullNative();
    }
  }
}

///home native
class HomeNativeAdsWidget extends StatefulWidget {
  final bool isHomeSmallNative;
  final NativeAd? showHomeNativeAd;
  final double? Homeheight;

  const HomeNativeAdsWidget({
    super.key,
    required this.showHomeNativeAd,
    required this.isHomeSmallNative,
    this.Homeheight,
  });

  @override
  State<HomeNativeAdsWidget> createState() => _HomeNativeAdsWidgetState();
}

/// home Native ads
class _HomeNativeAdsWidgetState extends State<HomeNativeAdsWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    showLog("CHECK NULL HOME >> ${AdsLoadUtil.ishomeNativeAdLoaded.value}");
    return Obx(
      () =>
          AdsLoadUtil.ishomeNativeAdLoaded.value &&
              widget.showHomeNativeAd != null
          ? StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  margin: EdgeInsets.only(bottom: 40.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: Colors.transparent,
                  ),
                  padding: EdgeInsets.only(bottom: 10.w, top: 0.w),
                  width: 1080.w,
                  height: widget.isHomeSmallNative ? 150 : 300,
                  child: AdWidget(ad: widget.showHomeNativeAd!),
                );
              },
            )
          : getShimmerWidget(),
    );
  }

  Widget getShimmerWidget() {
    if (AdsLoadUtil.ishomeNativeAdFailed.value) {
      return Container(height: 0);
    } else {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 50.w, vertical: 20.h),

        child: widget.isHomeSmallNative
            ? ShimmerSmallNative()
            : ShimmerBigNative(),
      );
    }
  }
}
