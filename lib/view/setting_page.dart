import 'dart:async';
import 'dart:io';

import 'package:charmai/view/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../ads/AdsVariable.dart';
import '../ads/AppLifeReactor.dart';
import '../ads/analytics_service.dart';
import '../ads/appOpenAdManager.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/constant.dart';
import '../utils/custom_appbar.dart';
import '../utils/globalVariables.dart';
import '../utils/initialized.dart';
import '../utils/navigation.dart';
import '../utils/setting_button.dart';
import 'language_screen.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  bool isPresed = false;
  Timer? _debounceTimer;
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;


  @override
  void initState() {
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);
    FirebaseAnalyticsService.logEvent(eventName: "CA_SETTING_SCREEN");
    super.initState();
  }

  final InitializationHelper _initializationHelper = InitializationHelper();


  Future<void> appReviewInAppStore() async {
    try {
      const String iosAppId = appIdIos;
      final InAppReview inAppReview = InAppReview.instance;
      await inAppReview.openStoreListing(
        appStoreId: iosAppId,
      ); // Replace with your iOS app ID
    } catch (e) {
      showLog('Error requesting in-app review: $e');
    }
  }

  void shareApp(String iosAppId) async {
    if (_debounceTimer?.isActive ?? false) return; // Prevent multiple triggers
    _debounceTimer = Timer(
      Duration(seconds: 1),
      () {},
    ); // Set debounce duration
    if (Platform.isIOS) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String packageName = packageInfo.packageName;
      showLog(packageName);
      if (Platform.isIOS) {
        final String url = 'https://apps.apple.com/app/id$iosAppId';
        Share.share(url);
      } else {
        final String webUrl =
            'https://play.google.com/store/apps/details?id=$packageName';
        Share.share(webUrl);
      }
    } else if (Platform.isAndroid) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String packageName = packageInfo.packageName;
      showLog(packageName);
      if (Platform.isIOS) {
        final String url = 'https://apps.apple.com/app/id$iosAppId';
        Share.share(url);
      } else {
        final String webUrl =
            'https://play.google.com/store/apps/details?id=$packageName';
        Share.share(webUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var heightof = MediaQuery.of(context).size.height;
    var widthof = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppbar(
                  onTap: (){
                    AppNavigation.NavigationBack(context);
                  },
                  name: AppLocalizations.of(context)?.setting ??"Setting",
                showPremium: false,
              ),

              SizedBox(height: 20.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10.w, right: 10.w,
                    bottom: 15.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      SettingButton(
                        height: 150.h,
                        width: 1080.w,
                        text:
                            AppLocalizations.of(context)?.selectelanguage ??
                            "Language",
                        image: "assets/setting/languag.png",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      LanguagePage(isFromHomeScreen: true),
                            ),
                          );

                        },
                      ),
                      SizedBox(height: 20.h),
                      SettingButton(
                        height: 150.h,
                        width: 1080.w,
                        text: AppLocalizations.of(context)?.rateup ??"Rate Us",
                        image: "assets/setting/rateus.png",
                        onTap: () async {
                          appReviewInAppStore();
                        },
                      ),
                      SizedBox(height: 20.h),
                      SettingButton(
                        height: 150.h,
                        width: 1080.w,
                        text:
                            AppLocalizations.of(context)?.shareapp ??
                            "shareapp",
                        image: "assets/setting/share.png",
                        onTap: () async {
                          shareApp(appIdIos);
                        },
                      ),
                      SizedBox(height: 20.h),
                      SettingButton(
                        height: 150.h,
                        width: 1080.w,
                        text:
                            AppLocalizations.of(context)?.privacypolicy ??
                            "privacypolicy",
                        image: "assets/setting/privacyPolicy.png",
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PrivacyPolicyPage('privacy'),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
