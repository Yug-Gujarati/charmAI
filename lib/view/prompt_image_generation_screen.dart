import 'package:cached_network_image/cached_network_image.dart';
import 'package:charmai/view/premium_screen.dart';
import 'package:charmai/view_model/coin_managment.dart';
import 'package:charmai/view_model/image_generation_provider.dart';
import 'package:dotted_border/dotted_border.dart';
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
import 'coin_purchase_screen.dart';

class PromptImageGenerationScreen extends StatefulWidget {
  final String image;
  final String prompt;
  final String title;

  const PromptImageGenerationScreen({super.key, required this.image, required this.prompt, required this.title});

  @override
  State<PromptImageGenerationScreen> createState() => _PromptImageGenerationScreenState();
}

class _PromptImageGenerationScreenState extends State<PromptImageGenerationScreen> {


  @override
  void initState() {
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_PROMPT_IMAGE_GENERATION_SCREEN");

    super.initState();
  }


  int currentCoins = 0;

  Future<void> _fetchCoins() async {
    String deviceId = await context.read<CoinProvider>().getRandomId();

    await context.read<CoinProvider>().fetchCoins();

    setState(() {
      currentCoins = context.read<CoinProvider>().coins;
      showLog("Correct coin is $currentCoins");
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.mainAppBackground,
      body:Padding(
        padding: EdgeInsets.only(left: 50.w, right: 50.w),
        child: Column(
          children: [
            CustomAppbar(
              onTap: () {
                AdsSplashUtils.onShowAds(context, () {
                  AppNavigation.NavigationBack(context);
                });
              },
              name: widget.title,
              showPremium: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Consumer<ImageGenerationProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        vSpace(20.h),

                        CustomImageSelectionCard(
                          networkImage: widget.image,
                          isLoading: provider.isLoading,
                          onTap: () {
                            //imageProvider.pickImage();
                          },
                        ),
                        SizedBox(height: 30.h,),
                        Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      provider.pickBoyImage();

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
                                        height: 350.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            //color: Color(0xFF4C1D95),
                                            width: 2,
                                          ),
                                        ),
                                          padding: EdgeInsets.all(10),
                                          child: provider.boyImage != null
                                              ? ClipRRect(
                                            borderRadius: BorderRadius.circular(500),
                                            child: Image.file(
                                              provider.boyImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                              : Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add),
                                              SizedBox(height: 10),
                                              CustomText(
                                                text: AppLocalizations.of(context)?.manfaceimage ??"Man Face Image",
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
                                hSpace(50.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      provider.pickGirlImage();

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
                                        height: 350.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            //color: Color(0xFF4C1D95),
                                            width: 2,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: provider.girlImage != null
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(500),
                                          child: Image.file(
                                            provider.girlImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add),
                                            SizedBox(height: 10),
                                            CustomText(
                                              text: AppLocalizations.of(context)?.womanfaceimage ??"Women Face Image",
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
                              ],
                            ),
                        SizedBox(height: 80.h,),
                        Consumer<CoinProvider>(
                          builder: (context, value, child) {
                            return CustomeButtomWithImage(
                              height: 130.h,
                              width: 950.w,
                              image: "assets/change_hair_style/button.png",
                              onTap: () {
                                if(provider.isLoading){
                                  showToast("Please wait we generating image");
                                }
                                 else {
                                  if (value.coins >=
                                      AdsVariable
                                          .ca_reduce_coin_on_ai_lab_api) {
                                    provider.generateImage(context, widget.prompt);
                                  } else {
                                    if (GlobalVariables.isPremiumUser) {
                                      showLog("this is coin ");
                                      AppNavigation.NavigationPush(
                                        context,
                                        CoinPurchase(
                                          isFromSplash: false,
                                          onDone: () {
                                            showLog("this is coin on done");
                                            provider.generateImage(context, widget.prompt);
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
                                              provider.generateImage(context, widget.prompt);

                                            } else {
                                              _fetchCoins();
                                            }
                                          },

                                              () {
                                            AppNavigation.NavigationBack(context);
                                            provider.generateImage(context, widget.prompt).then((value) {
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
                                                provider.generateImage(context, widget.prompt);
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
                                    text: AppLocalizations.of(context)?.generateimage ??"Generate Image",
                                    fontSize: 50,
                                    fontFamily: 'medium',
                                    width: 500,
                                    textColor: AppColors.buttonText,
                                    maxline: 1,
                                    align: TextAlign.end,
                                  ),
                                  SizedBox(width: 50.w),
                                  CustomText(
                                    text:   "- ${AdsVariable.ca_reduce_coin_on_ai_lab_api}  ",
                                    fontSize: 50,
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
                          }
                        ),

                      ],
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
