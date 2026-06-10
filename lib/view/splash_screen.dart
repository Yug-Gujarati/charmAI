
import 'package:charmai/view/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:ui';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../l10n/app_localizations.dart';
import '../ads/AdsVariable.dart';
import '../ads/ads_init_utils.dart';
import '../ads/ads_loading_util.dart';
import '../ads/analytics_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_text.dart';
import '../utils/globalVariables.dart';
import '../utils/navigation.dart';
import '../view_model/category_provider.dart';
import 'bottom_nav_bar_screen.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();

    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      await AdsSplashUtils().getOnlineIds(
        preLoads: () {
          loadPreLoadAds();
        }, navigateScreen: () {
        navigation();

      },
      );
      Future.microtask(() => context.read<CategoryProvider>().loadCategories());
      FirebaseAnalyticsService.logEvent(eventName: "CA_SPLASH_SCREEN");
    });
  }


  Future<void> navigation() async{
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      AppNavigation.NavigationPushReplacement(
          context, LanguagePage(isFromHomeScreen: false)
      );

    } else {
      if (GlobalVariables.isPremiumUser) {
        AppNavigation.NavigationPushReplacement(
            context, BottomNavBarScreen()
        );
      } else {
        AppNavigation.NavigationPushReplacement(
            context, PremiumScreen(isFromSplash: true, onDone: (){})
        );
      }
    }
  }

  void loadPreLoadAds() async {
    showLog("Call Method loadPreLoadAds");
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    showLog('isFirstLaunch Splash screen $isFirstLaunch');
    showLog("AdsVariable.isFirstTime ----> $isFirstLaunch");

    if (isFirstLaunch) {
      AdsVariable.languageAd = await AdsLoadUtil().loadNative(AdsVariable.ca_language_nativeAd, false);
      showLog("AdsVariable.nativeAdLanguage ---> ${AdsVariable.languageAd}");
      AdsVariable.introFullAd = await AdsLoadUtil().loadIntroNative(AdsVariable.ca_full_nativeAd, false);
      showLog("AdsVariable.full_nativead ---> ${AdsVariable.languageAd}");
    } else {
      showLog("Pre-load another native ad if available");
    }
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/splash/912ef66b-0683-4aba-a815-7f7d018532ea.mp4',
    );

    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.setVolume(0.0);
    _videoController.play();

    if (mounted) {
      setState(() => _isVideoInitialized = true);
    }
  }


  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Container(
              width: 1080.w,
              height: 1000.w,
              padding: EdgeInsets.all(5.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(400.w),
                 child:  _isVideoInitialized
                     ? AspectRatio(
                   aspectRatio: _videoController.value.aspectRatio,
                   child: VideoPlayer(_videoController),
                 )
                     : ClipRRect(
                   child: Image.asset("assets/splash/5.jpeg"),
                 )

                 //Image.asset("assets/splash/912ef66b-0683-4aba-a815-7f7d018532ea.gif")//Lottie.asset("assets/splash/animation.json", height: 1000.h, )
                 //Image.asset(
                //   'assets/splash/app_icon.png',
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
          ),


          // Title "GlamAI"
          GradiantCustomText(
            text: AppLocalizations.of(context)?.charmAI ??'CharmAI',
            fontSize: 140,
            fontFamily: 'bold',
            width: 900,
            maxline: 1,
            align: TextAlign.center,
          ),


          SizedBox(height: 10.h),


          Spacer(),


          // Container(
          //   width: 1000.w,
          //   height: 100.h,
          //   child: Lottie.asset("assets/splash/l90p66FNFM.json"),
          // ),


         CustomText(
            text: AppLocalizations.of(context)?.thisActionmay ??'This action may contain ads',
            fontSize: 35,
            textColor: Colors.grey,
            fontFamily: 'regular',
            width: 600,
            maxline: 1,
            align: TextAlign.center,
          ),
          SizedBox(height: 60.h),

          // Spacer(),
        ],
      ),
    );
  }
}
