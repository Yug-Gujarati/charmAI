import 'package:charmai/view/premium_screen.dart';
import 'package:charmai/view_model/image_picker_provider.dart';
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
import '../view_model/dating_redy_image_provider.dart';
import 'coin_purchase_screen.dart';

class DatingRedyImage extends StatefulWidget {
  const DatingRedyImage({super.key});

  @override
  State<DatingRedyImage> createState() => _DatingRedyImageState();
}

class _DatingRedyImageState extends State<DatingRedyImage> {

  @override
  void initState() {
    // TODO: implement initState
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_IMAGE_ENHANCEMENT");

    super.initState();
  }


  int currentCoins = 0;

  Future<void> _fetchCoins() async {
    String deviceId = await context.read<CoinProvider>().getRandomId();

    await context.read<CoinProvider>().fetchCoins();

    // Now read the updated value
    setState(() {
      currentCoins = context.read<CoinProvider>().coins;
      showLog("Correct coin is $currentCoins"); // Now it will match!
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
                context.read<DatingRedyImageProvider>().clearResults();
                context.read<ImagePickerProvider>().clearImage();
                AdsSplashUtils.onShowAds(context, () {
                  AppNavigation.NavigationBack(context);
                });
              },
              name: AppLocalizations.of(context)?.aidatingimage ??"AI Dating Image",
              showPremium: true,
            ),
            Expanded(
              child: Consumer3<DatingRedyImageProvider, ImagePickerProvider, CoinProvider>(
                builder: (context, DatingProvider, imagePickerProvider, coinProvider, child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        vSpace(20.h),
                        CustomImageSelectionCard(
                          originalImage: imagePickerProvider.selectedImage,
                          //generatedImage: DatingProvider.resultImage,
                          isLoading: DatingProvider.isLoading,
                          onTap: () {
                            imagePickerProvider.pickImage();
                          },
                        ),
                        SizedBox(height: 40.h),

                        CustomeButtomWithImage(
                          height: 130.h,
                          width: 950.w,
                          image: "assets/change_hair_style/button.png",
                          onTap: () {
                            if (imagePickerProvider.selectedImage == null) {
                              showToast("Please first pick image");
                            } else {
                              if (coinProvider.coins >=
                                  AdsVariable
                                      .ca_reduce_coin_on_gemini_api) {
                                DatingProvider.datingImageGenerator(
                                    imagePickerProvider.selectedImage!,
                                    context
                                );
                              } else {
                                if (GlobalVariables.isPremiumUser) {
                                  AppNavigation.NavigationPush(
                                    context,
                                    CoinPurchase(
                                      isFromSplash: false,
                                      onDone: () {
                                        DatingProvider.datingImageGenerator(
                                            imagePickerProvider.selectedImage!,
                                            context
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  if (AdsVariable.ca_showRewaredAd_gemini_api) {
                                    DialogService.rewardAdorPremimDialog(
                                      context,
                                          () {
                                        if (coinProvider.coins >=
                                            AdsVariable
                                                .ca_reduce_coin_on_gemini_api) {
                                          DatingProvider.datingImageGenerator(
                                              imagePickerProvider.selectedImage!,
                                              context
                                          );
                                        } else {
                                          _fetchCoins();
                                        }
                                      },

                                          () {
                                            DatingProvider.datingImageGenerator(
                                                imagePickerProvider.selectedImage!,
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
                                            DatingProvider.datingImageGenerator(
                                                imagePickerProvider.selectedImage!,
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
                                text: AppLocalizations.of(context)?.aidatingimage ??"AI Dating Image",
                                fontSize: 50,
                                fontFamily: 'medium',
                                width: 500,
                                textColor: AppColors.buttonText,
                                maxline: 1,
                                align: TextAlign.center,
                              ),
                              SizedBox(width: 50.w),
                              Text(
                                "- ${AdsVariable.ca_reduce_coin_on_gemini_api}  ",
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


