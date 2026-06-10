import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../l10n/app_localizations.dart';


@protected
final scaffoldGlobalKey = GlobalKey<ScaffoldState>();

class LoadingScreen {
  final GlobalKey globalKey;

  LoadingScreen(this.globalKey);

  show([String? text]) {
    showDialog<String>(
      context: Get.context!,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: PopScope(
            canPop: false,
            child: Container(
              height: Get.height,
              width: Get.height,
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 100.w),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Transform.scale(
                      scale: 1,
                      child: Lottie.asset(
                        "assets/premium/sparkels.json",
                        height: 250.h,
                      ),
                    ),
                    // Add spacing
                    Text(
                      AppLocalizations.of(context)?.pleaseWait ??'Please Wait For A While',
                      style: TextStyle(
                          color: Colors.white, fontSize: 48.sp, fontWeight: FontWeight.w700),
                    ),
                    // Text indicating ads are being loaded
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  hide() {
    if (Get.context == null) return;
    Navigator.pop(Get.context!);
  }
}

@protected
var loadingScreen = LoadingScreen(scaffoldGlobalKey);
