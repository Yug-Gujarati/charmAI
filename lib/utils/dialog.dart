import 'dart:io';
import 'dart:math';

import 'package:charmai/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../ads/AdsVariable.dart';
import '../ads/ads_init_utils.dart';
import '../ads/ads_loading_util.dart';
import '../l10n/app_localizations.dart';
import '../view/premium_screen.dart';
import '../view_model/coin_managment.dart';
import 'app_constants.dart';
import 'custom_appbar.dart';
import 'custom_text.dart';
import 'custome_buttom.dart';
import 'globalVariables.dart';
import 'navigation.dart';

class DialogService {
  static void showLoading(BuildContext context) {
    if (Platform.isIOS) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SizedBox(
            height: 220.h,
            width: 250.w,
            child: Center(
              child: Transform.scale(
                scale: 2,
                child: Lottie.asset(
                  "assets/premium/sparkels.json",
                  height: 20.h,
                ),
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: Center(
              child: Transform.scale(
                scale: 2,
                child: Lottie.asset(
                  "assets/premium/sparkels.json",
                  height: 20.h,
                ),
              ),
            ),
          );
        },
      );
    }
  }



  static Future<void> rewardAdorPremimDialog(
    BuildContext context,
    Function onComplate,
    Function onPremium,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 550.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/change_hair_style/popup.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                /// Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomeButtomWithImage(
                      height: 60.h,
                      width: 60.w,
                      isShowAd: false,
                      child: Container(),
                      image: "assets/change_hair_style/cancle.png",
                      onTap: () {
                        AppNavigation.NavigationBack(context);
                      },
                    ),
                  ],
                ),

                /// Text (use outerContext for localization)
                CustomText(
                  text: AppLocalizations.of(context)?.choosehowtoliketogenerate ??"Choose how you'd like to continue generating image",
                  fontSize: 50,
                  fontFamily: 'medium',
                  textColor: AppColors.primaryText,
                  align: TextAlign.center,
                  width: 600,
                  maxline: 3,
                ),

                SizedBox(height: 40.h),

                /// Upgrade Button
                CustomeButtomWithImage(
                  height: 100.h,
                  width: 700.w,
                  isShowAd: false,
                  image: "assets/intro/next_pressed.png",
                  onTap: () async {
                    AppNavigation.NavigationBack(context);
                    AppNavigation.NavigationPush(
                      context,
                      PremiumScreen(
                        isFromSplash: false,
                        onDone: () async {
                          showLog("select premium");
                          onPremium();
                        },
                      ),
                    );
                  },
                  child: Center(
                    child: CustomText(
                      text: AppLocalizations.of(context)?.upgradeToPremium ??"Upgrade to Premium",
                      maxline: 1,
                      fontFamily: 'medium',
                      width: 450,
                      fontSize: 40,
                      textColor: AppColors.buttonText,
                      align: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                /// Show Ad Button
                Consumer<CoinProvider>(
                  builder: (providerContext, value, child) {
                    return CustomeButtomWithImage(
                      height: 100.h,
                      width: 700.w,
                      isShowAd: false,
                      image: "assets/change_hair_style/viewAd.png",
                      onTap: () async {
                        AppNavigation.NavigationBack(context);
                        AdsLoadUtil.loadAndShowRewardedAdOnce(
                          context: context,
                          adId: AdsVariable.ca_rewardedAd,
                          onDismissed: () {
                            onComplate();
                          },
                          onRewarded: (int credits) {
                            final coinProvider = Provider.of<CoinProvider>(context, listen: false);
                            coinProvider.incrementCoins(credits);
                            coinProvider.fetchCoins();
                          },
                        );
                      },
                      child: Center(
                        child: CustomText(
                          text: AppLocalizations.of(context)?.getrewared ??"Get reward",
                          maxline: 1,
                          fontFamily: 'medium',
                          width: 450,
                          fontSize: 40,
                          textColor: AppColors.primaryText,
                          align: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void deleteDialog(BuildContext context, Function onComplate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 630.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/change_hair_style/popup.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                /// Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomeButtomWithImage(
                      height: 80.h,
                      width: 80.w,
                      isShowAd: false,
                      child: Container(),
                      image: "assets/change_hair_style/cancle.png",
                      onTap: () {
                        AppNavigation.NavigationBack(context);
                      },
                    ),
                  ],
                ),
                CustomText(
                  text: AppLocalizations.of(context)?.delete ??"Delete",
                  fontSize: 60,
                  fontFamily: 'bold',
                  textColor: AppColors.primaryText,
                  align: TextAlign.center,
                  width: 600,
                  maxline: 2,
                ),

                /// Text (use outerContext for localization)
                CustomText(
                  text: AppLocalizations.of(context)?.areyousureyouwant ??"Are you sure you want to delete this image",
                  fontSize: 40,
                  fontFamily: 'medium',
                  textColor:  AppColors.primaryText,
                  align: TextAlign.center,
                  width: 600,
                  maxline: 2,
                ),

                SizedBox(height: 40.h),

                /// Upgrade Button
                CustomeButtomWithImage(
                  height: 120.h,
                  width: 720.w,
                  isShowAd: false,
                  image: "assets/intro/next_pressed.png",
                  onTap: () async {
                    AppNavigation.NavigationBack(context);
                    onComplate();
                  },
                  child: Center(
                    child: CustomText(
                      text: AppLocalizations.of(context)?.delete ?? "Delete",
                      maxline: 1,
                      fontFamily: 'medium',
                      width: 450,
                      fontSize: 40,
                      textColor: AppColors.buttonText,
                      align: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                /// Show Ad Button
                CustomeButtomWithImage(
                  height: 120.h,
                  width: 720.w,
                  isShowAd: false,
                  image: "assets/change_hair_style/viewAd.png",
                  onTap: () async {
                    AppNavigation.NavigationBack(context);
                  },
                  child: Center(
                    child: CustomText(
                      text: AppLocalizations.of(context)?.cancel ??"Cancel",
                      maxline: 1,
                      fontFamily: 'medium',
                      width: 450,
                      fontSize: 40,
                      textColor: Colors.white,
                      align: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
