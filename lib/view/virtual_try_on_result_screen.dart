import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../ads/analytics_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/navigation.dart';
import '../utils/theme.dart';
import '../view_model/coin_managment.dart';

class VirtualTryOnResultScreen extends StatefulWidget {
  final File resultImage;

  const VirtualTryOnResultScreen({super.key, required this.resultImage});

  @override
  State<VirtualTryOnResultScreen> createState() =>
      _VirtualTryOnResultScreenState();
}

class _VirtualTryOnResultScreenState extends State<VirtualTryOnResultScreen> {
  bool _isSaving = false;
  int currentCoins = 0;

  @override
  void initState() {
    // TODO: implement initState
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_VIRTUAL_TRYON_RESULT_SCREEN");
    super.initState();
  }

  Future<void> _fetchCoins() async {
    String deviceId = await context.read<CoinProvider>().getRandomId();

    await context.read<CoinProvider>().fetchCoins();

    // Now read the updated value
    setState(() {
      currentCoins = context.read<CoinProvider>().coins;
      showLog("Correct coin is $currentCoins"); // Now it will match!
    });

    final InAppReview _inAppReview = InAppReview.instance;
    _inAppReview.requestReview();
  }



  Future<void> _saveToGallery() async {
    setState(() {
      _isSaving = true;
    });
 
    try {
      // Use gal package to save to gallery
      await Gal.putImage(widget.resultImage.path);
      showToast("Saved to gallery successfully!");
    } catch (e) {
      showLog("Error saving to gallery: $e");
      showToast("Failed to save image");
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _shareImage() async {
    try {
      await Share.shareXFiles([
        XFile(widget.resultImage.path),
      ], text: 'Check out my virtual try-on result from GlamAI!');
    } catch (e) {
      showLog("Error sharing image: $e");
      showToast("Failed to share image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainAppBackground,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.w),
        child: Column(
          children: [
            CustomAppbar(
              onTap: () => AppNavigation.NavigationBack(context),
              name: AppLocalizations.of(context)?.youcreation ??"Your Creation",
              showPremium: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    vSpace(30.h),
                    Hero(
                      tag: widget.resultImage.path,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.r),
                          child: Image.file(
                            widget.resultImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    vSpace(60.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomeButtomWithImageFit(
                            height: 100.h,
                            width: 450.w,
                            onTap: () {
                              if (!_isSaving) {
                                _saveToGallery();
                              }
                            },
                            isShowAd: false,
                            image: 'assets/priview/recordings.png',
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isSaving)
                                    SizedBox(
                                      height: 40.h,
                                      width: 40.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.download_rounded,
                                      color: Colors.white,
                                    ),
                                  hSpace(20.w),
                                  CustomText(
                                    text: AppLocalizations.of(context)?.save ??"Save",
                                    fontSize: 45,
                                    textColor: Colors.white,
                                    fontFamily: "medium",
                                    width: 150,
                                    maxline: 1,
                                    align: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        hSpace(30.w),
                        Expanded(
                          child: CustomeButtomWithImageFit(
                            height: 100.h,
                            width: 450.w,
                            onTap: _shareImage,
                            isShowAd: false,
                            image: 'assets/intro/next_pressed.png',
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.share_rounded,
                                    color: AppColors.buttonText,
                                  ),
                                  hSpace(20.w),
                                  CustomText(
                                    text: AppLocalizations.of(context)?.share ??"Share",
                                    fontSize: 45,
                                    textColor: AppColors.buttonText,
                                    fontFamily: "medium",
                                    width: 150,
                                    maxline: 1,
                                    align: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    vSpace(50.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
