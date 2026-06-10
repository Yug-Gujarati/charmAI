import 'dart:io';


import 'package:charmai/view/premium_screen.dart';
import 'package:charmai/view_model/image_picker_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../ads/AdsVariable.dart';
import '../ads/ads_init_utils.dart';
import '../ads/analytics_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/cloth_type_selector.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_image_selection_card.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/dialog.dart';
import '../utils/globalVariables.dart';
import '../utils/navigation.dart';
import '../utils/theme.dart';
import '../view_model/coin_managment.dart';
import '../view_model/virtual_try_on_provider.dart';
import 'coin_purchase_screen.dart';

class VirtualTryOnScreen extends StatefulWidget {
  const VirtualTryOnScreen({super.key});

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {


  @override
  void initState() {
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_VIRTUALTRYON_SCREEN");
    super.initState();
  }

  Future<void> _fetchCoins() async {
    await context.read<CoinProvider>().fetchCoins();
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VirtualTryOnProvider>().clearResults();
        context.read<ImagePickerProvider>().clearImage();
      }
    });
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainAppBackground,
      body: Padding(
        padding: EdgeInsets.only(left: 50.w, right: 50.w),
        child: Column(
          children: [
            CustomAppbar(
              onTap: () {
                context.read<VirtualTryOnProvider>().clearResults();
                context.read<ImagePickerProvider>().clearImage();

                AdsSplashUtils.onShowAds(context, () {
                  AppNavigation.NavigationBack(context);
                });
              },
              name: AppLocalizations.of(context)?.virtualtryon ??"Virtual Try-On",
              showPremium: true,
            ),
            Expanded(
              child: Consumer3<VirtualTryOnProvider, ImagePickerProvider, CoinProvider>(
                builder: (context, provider, imageProvider, coinProvider, child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        vSpace(20.h),
                        CustomImageSelectionCard(
                          originalImage: imageProvider.selectedImage,
                          //generatedImage: provider.resultImage,
                          isLoading: provider.isLoading,
                          onTap: () {
                            imageProvider.pickImage();
                          },
                        ),
                        SizedBox(height: 60.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  provider.pickImage();

                                },
                                child: DottedBorder(
                                  options: CircularDottedBorderOptions(
                                    dashPattern: [10, 5],
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF4FC3F7),
                                        Color(0xFFF48FB1)
                                      ],
                                    ),
                                  ),
                                  child: Container(
                                      height: 400.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          //color: Color(0xFF4C1D95),
                                          width: 2,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(10.w),
                                      child: provider.clothSelectImage != null
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(500.r),
                                            child: Image.file(
                                              provider.clothSelectImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset("assets/change_hair_style/image_select.png", height: 100.h),
                                                SizedBox(height: 10.h),
                                                CustomText(
                                                  text: AppLocalizations.of(context)?.clothimage ??"Cloth Image",
                                                  fontSize: 40,
                                                  textColor: Colors.white,
                                                  fontFamily: 'medium',
                                                  width: 400,
                                                  align: TextAlign.center,
                                                  maxline: 1,
                                                ),
                                              ],
                                            ),
                                    ),
                                ),

                              ),
                            ),
                            Expanded(child: ClothesTypeDropdown()),
                          ],
                        ),

                        SizedBox(height: 50.h),

                        CustomeButtomWithImage(
                          height: 130.h,
                          width: 950.w,
                          image: "assets/change_hair_style/button.png",
                          onTap: ()  {
                            if(provider.clothSelectImage == null){
                              showToast("Please select cloth image first");
                            }
                            else if(imageProvider.selectedImage == null){
                              showToast("Please select your full body image first");
                            }
                            else {
                              showLog("this is else method");
                              if (coinProvider.coins >=
                                  AdsVariable
                                      .ca_reduce_coin_on_ai_lab_api) {
                                showLog("start api call");
                                provider.virtualTryOn(
                                  imageProvider.selectedImage!,
                                  provider.clothSelectImage!,
                                  context,
                                );
                              } else {
                                showLog("start api call no coin");
                                if (GlobalVariables.isPremiumUser) {
                                  showLog("premium user");
                                  AppNavigation.NavigationPush(
                                    context,
                                    CoinPurchase(
                                      isFromSplash: false,
                                      onDone: () {
                                        provider.virtualTryOn(
                                          imageProvider.selectedImage!,
                                          provider.clothSelectImage!,
                                          context,
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  showLog("Rewared ad ${AdsVariable.ca_showRewardedAd_ai_lab_api}");
                                  if (AdsVariable
                                      .ca_showRewardedAd_ai_lab_api) {
                                    showLog("Rewared ad diolag ${AdsVariable.ca_showRewardedAd_ai_lab_api}");
                                    DialogService.rewardAdorPremimDialog(
                                      context,
                                          () {
                                        if (coinProvider.coins >=
                                            AdsVariable
                                                .ca_reduce_coin_on_ai_lab_api) {
                                          provider.virtualTryOn(
                                            imageProvider.selectedImage!,
                                            provider.clothSelectImage!,
                                            context,
                                          );
                                        } else {
                                          _fetchCoins();
                                        }
                                      },
                                          () {
                                          provider.virtualTryOn(
                                            imageProvider.selectedImage!,
                                            provider.clothSelectImage!,
                                            context,
                                          ).then((value) {
                                            _fetchCoins();
                                          },);
                                      },
                                    );
                                  } else {
                                    showLog("navigate to premium");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PremiumScreen(
                                              isFromSplash: false,
                                              onDone: () async {
                                                provider.virtualTryOn(
                                                  imageProvider.selectedImage!,
                                                  provider.clothSelectImage!,
                                                  context,
                                                );
                                              },
                                            ),
                                      ),
                                    ).then((value) {
                                      _fetchCoins();
                                    });
                                  }
                                }
                              }
                            }
                          },
                          isShowAd: false,
                          child: Row(
                            children: [
                              Spacer(),
                              CustomText(
                                text: AppLocalizations.of(context)?.tryonnow ??"Try On Now",
                                fontSize: 50,
                                fontFamily: 'medium',
                                width: 500,
                                textColor: AppColors.buttonText,
                                maxline: 1,
                                align: TextAlign.center,
                              ),
                              SizedBox(width: 50.w),
                              Text(
                                "- ${AdsVariable.ca_reduce_coin_on_ai_lab_api}  ",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.buttonText,
                                  fontFamily: 'medium',
                                  fontSize: 45.sp,
                                ),
                              ),
                              Image.asset(
                                "assets/home/Group.png",
                                height: 30.h,
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                        SizedBox(height: 50.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
