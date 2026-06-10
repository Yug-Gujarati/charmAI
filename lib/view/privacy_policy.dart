import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../ads/AppLifeReactor.dart';
import '../ads/analytics_service.dart';
import '../ads/appOpenAdManager.dart';
import '../l10n/app_localizations.dart';
import '../utils/constant.dart';
import '../utils/custom_appbar.dart';
import '../utils/navigation.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final String from;

  const PrivacyPolicyPage(this.from, {super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool isPresed = false;
  bool _isLoading = true;
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;
  WebViewController? controller;

  @override
  void initState() {
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);
    if (widget.from == "privacy") {
      FirebaseAnalyticsService.logEvent(eventName: "CA_PRIVACY_POLICY");
    } else {
      FirebaseAnalyticsService.logEvent(eventName: "CA_TERMS_OF_USE");
    }

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      navigate();
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..enableZoom(true)
        ..loadRequest(Uri.parse("https://yug-gujarati.github.io/privacy_policy/"));
        //..loadFlutterAsset('assets/Privacy_Policy.html');

    });
    super.initState();
  }

  void navigate() {
    Timer(Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [

              Padding(
                padding: EdgeInsets.only(left: 50.w, right: 50.w),
                child: CustomAppbar(
                    onTap: (){
                      AppNavigation.NavigationBack(context);
                    },
                    name: AppLocalizations.of(context)?.privacypolicy ??"Privacy Policy",
                  showPremium: false,
                ),
              ),


              SizedBox(
                height: 20.h,
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (controller == null && _isLoading) ...[
                      Center(
                          child: Transform.scale(
                            scale: 2,
                            child: Lottie.asset(
                              "assets/premium/sparkels.json",
                              height: 200.h,
                            ),
                          ),)
                    ] else ...[
                      WebViewWidget(controller: controller!),
                    ], // Loading indicator
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
