import 'package:charmai/view/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../ads/AdsVariable.dart';
import '../ads/ads_init_utils.dart';
import '../ads/analytics_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_image_selection_card.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/dialog.dart';
import '../utils/globalVariables.dart';
import '../utils/navigation.dart';
import '../utils/theme.dart';
import '../view_model/coin_managment.dart';
import '../view_model/face_buty_provider.dart';
import '../view_model/image_picker_provider.dart';
import 'coin_purchase_screen.dart';

class FaceButyEnhance extends StatefulWidget {
  const FaceButyEnhance({super.key});

  @override
  State<FaceButyEnhance> createState() => _FaceButyEnhanceState();
}

class _FaceButyEnhanceState extends State<FaceButyEnhance> {

  @override
  void initState() {
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_HAIRSTYLE_SCREEN");

    super.initState();
  }


  int currentCoins = 0;

  Future<void> _fetchCoins() async {
    String deviceId = await context.read<CoinProvider>().getRandomId();

    await context.read<CoinProvider>().fetchCoins();

    // Now read the updated value
    setState(() {
      currentCoins = context.read<CoinProvider>().coins;
      showLog("Correct coin is $currentCoins");
    });
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
                context.read<FaceBeautyProvider>().clearResults();
                context.read<ImagePickerProvider>().clearImage();
                AdsSplashUtils.onShowAds(context, () {
                  AppNavigation.NavigationBack(context);
                });
              },
              name: AppLocalizations.of(context)?.facebeauty ??"Face Beauty",
              showPremium: true,
            ),

            Expanded(
              child: Consumer2<FaceBeautyProvider, ImagePickerProvider>(
                builder: (context, faceBeautyProvider, imageEditorProvider, child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        vSpace(20.h),
                        CustomImageSelectionCard(
                          originalImage: imageEditorProvider.selectedImage,
                          generatedImage: faceBeautyProvider.resultImage,
                          onTap: () {
                            imageEditorProvider.pickImage();
                          },
                          isLoading: faceBeautyProvider.isLoading,
                        ),




                        SizedBox(height: 200.h),



                        Consumer<CoinProvider>(
                          builder: (context, value, child) {
                            return CustomeButtomWithImage(
                              height: 130.h,
                              width: 950.w,
                              image: "assets/change_hair_style/button.png",
                              onTap: () {
                                if(faceBeautyProvider.isLoading){
                                  showToast("Please wait we generating image");
                                }
                                else if (imageEditorProvider.selectedImage == null) {
                                  showToast("Please pick image of face");
                                } else {
                                  if (value.coins >=
                                      AdsVariable
                                          .ca_reduce_coin_on_ai_lab_api) {
                                    faceBeautyProvider.applyFaceBeauty(
                                      imageEditorProvider.selectedImage!,
                                      context
                                    );
                                  } else {
                                    if (GlobalVariables.isPremiumUser) {
                                      showLog("this is coin ");
                                      AppNavigation.NavigationPush(
                                        context,
                                      CoinPurchase(
                                        isFromSplash: false,
                                        onDone: () {
                                          showLog("this is coin on done");
                                          faceBeautyProvider.applyFaceBeauty(
                                              imageEditorProvider.selectedImage!,
                                              context
                                          );
                                        },
                                      ),
                                      );
                                    } else {
                                      if (AdsVariable.ca_showRewardedAd_ai_lab_api) {
                                        DialogService.rewardAdorPremimDialog(
                                          context,
                                              () {
                                            if (value.coins >=
                                                AdsVariable
                                                    .ca_reduce_coin_on_ai_lab_api) {
                                              faceBeautyProvider.applyFaceBeauty(
                                                  imageEditorProvider.selectedImage!,
                                                  context
                                              );

                                            } else {

                                              _fetchCoins();
                                            }
                                          },

                                              () {
                                            AppNavigation.NavigationBack(context);

                                            faceBeautyProvider.applyFaceBeauty(
                                                imageEditorProvider.selectedImage!,
                                                context
                                            ).then((value) {
                                              _fetchCoins();
                                            },);

                                          },
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PremiumScreen(
                                              isFromSplash: false,
                                              onDone: () async {
                                                showLog("this is premium on done");
                                                faceBeautyProvider.applyFaceBeauty(
                                                    imageEditorProvider.selectedImage!,
                                                    context
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
                                    text: AppLocalizations.of(context)?.facebeauty ??"Face Beauty",
                                    fontSize: 50,
                                    fontFamily: 'medium',
                                    width: 500,
                                    textColor: AppColors.buttonText,
                                    maxline: 1,
                                    align: TextAlign.center,
                                  ),
                                  SizedBox(width: 50.w),
                                  CustomText(
                                    text:  "- ${AdsVariable.ca_reduce_coin_on_ai_lab_api}  ",
                                    fontSize: 45,
                                    fontFamily: 'medium',
                                    width: 100,
                                    textColor: AppColors.buttonText,
                                    maxline: 1,
                                    align: TextAlign.center,
                                  ),

                                  Image.asset(
                                    "assets/home/Group.png",
                                    height: 30.h,
                                  ),
                                  Spacer(),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 40.h),
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
