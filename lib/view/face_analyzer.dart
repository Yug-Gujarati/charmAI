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
import '../utils/hairstyle_data.dart';
import '../utils/navigation.dart';
import '../utils/theme.dart';
import '../view_model/coin_managment.dart';
import '../view_model/face_analyzer_provider.dart';
import 'coin_purchase_screen.dart';
import 'hair_style_changer.dart';

class FaceAnalyzer extends StatefulWidget {
  const FaceAnalyzer({super.key});

  @override
  State<FaceAnalyzer> createState() => _FaceAnalyzerState();
}

class _FaceAnalyzerState extends State<FaceAnalyzer> {


  @override
  void initState() {
    super.initState();
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_FACE_ANALYZE_SCREEN");
  }

  int currentCoins = 0;

  Future<void> _fetchCoins() async {
    final coinProvider = context.read<CoinProvider>();
    await coinProvider.getRandomId();

    await coinProvider.fetchCoins();

    // Now read the updated value
    if (!mounted) return;
    setState(() {
      currentCoins = coinProvider.coins;
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
                context.read<FaceAnalyzerProvider>().clearResults();
                context.read<ImagePickerProvider>().clearImage();
                AdsSplashUtils.onShowAds(context, () {
                  AppNavigation.NavigationBack(context);
                });
              },
              name:
                  AppLocalizations.of(context)?.faceAnalyzer ?? "Face Analyzer",
              showPremium: true,
            ),

            Expanded(
              child: Consumer2<FaceAnalyzerProvider, ImagePickerProvider>(
                builder: (context, faceAnalyzer, imageEditorProvider, child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        vSpace(20.h),
                        CustomImageSelectionCard(
                          originalImage: imageEditorProvider.selectedImage,
                          isLoading: faceAnalyzer.isLoading,
                          onTap: () {
                            imageEditorProvider.pickImage();
                            //DialogService.showImagePickerDialog(context);
                          },
                        ),
                        const SizedBox(height: 24),
                        if (faceAnalyzer.analysisResult != null) ...[
                          _buildResultSection(faceAnalyzer.analysisResult!),
                        ] else if (!faceAnalyzer.isLoading &&
                            imageEditorProvider.selectedImage != null) ...[
                          Center(
                            child: Consumer<CoinProvider>(
                              builder: (context, value, child) {
                                return CustomeButtomWithImage(
                                  height: 130.h,
                                  width: 950.w,
                                  image: "assets/change_hair_style/button.png",
                                  onTap: () {
                                    if (imageEditorProvider.selectedImage ==
                                        null) {
                                      showToast(
                                        "Please first pick image of face",
                                      );
                                    } else {
                                      if (value.coins >=
                                          AdsVariable
                                              .ca_reduce_coin_on_ai_lab_api) {
                                        faceAnalyzer.analyzeImage(
                                          imageEditorProvider.selectedImage!,
                                          context,
                                        );
                                      } else {
                                        if (GlobalVariables.isPremiumUser) {
                                          AppNavigation.NavigationPush(
                                            context,
                                            CoinPurchase(
                                              isFromSplash: false,
                                              onDone: () {
                                                faceAnalyzer.analyzeImage(
                                                  imageEditorProvider
                                                      .selectedImage!,
                                                  context,
                                                );
                                              },
                                            ),
                                          );
                                        } else {
                                          if (AdsVariable
                                              .ca_showRewardedAd_ai_lab_api) {
                                            DialogService.rewardAdorPremimDialog(
                                              context,
                                              () {
                                                if (value.coins >=
                                                    AdsVariable
                                                        .ca_reduce_coin_on_ai_lab_api) {
                                                  faceAnalyzer.analyzeImage(
                                                    imageEditorProvider
                                                        .selectedImage!,
                                                    context,
                                                  );
                                                } else {
                                                  _fetchCoins();
                                                }
                                              },

                                              () {
                                                faceAnalyzer
                                                    .analyzeImage(
                                                      imageEditorProvider
                                                          .selectedImage!,
                                                      context,
                                                    )
                                                    .then((value) {
                                                      _fetchCoins();
                                                    });
                                              },
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PremiumScreen(
                                                      isFromSplash: false,
                                                      onDone: () async {
                                                        faceAnalyzer.analyzeImage(
                                                          imageEditorProvider
                                                              .selectedImage!,
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
                                        text:
                                            AppLocalizations.of(
                                              context,
                                            )?.suggesthairstyle ??
                                            "Suggest Hairstyle",
                                        fontSize: 50,
                                        fontFamily: 'medium',
                                        width: 500,
                                        textColor: AppColors.buttonText,
                                        maxline: 1,
                                        align: TextAlign.center,
                                      ),
                                      SizedBox(width: 50.w),
                                      CustomText(
                                          text:   "- ${AdsVariable.ca_reduce_coin_on_ai_lab_api}  ",
                                          fontSize: 45,
                                          textColor: AppColors.buttonText,
                                          width: 100,
                                          maxline: 1
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
                          ),
                        ],
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

  Widget _buildResultSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text: AppLocalizations.of(context)?.faceshape ?? "Face Shape: ",
              fontSize: 45,
              textColor: Colors.white,
              fontFamily: 'medium',
              width: 300,
              maxline: 1,
            ),
            CustomText(
              text: data['faceShape'] ?? 'Unknown',
              fontSize: 45,
              textColor: Colors.white,
              fontFamily: 'regular',
              width: 200,
              maxline: 1,
              align: TextAlign.start,
            ),
          ],
        ),

        SizedBox(height: 40.h),
        _buildHairstyleList(
          title:
              AppLocalizations.of(context)?.recommendedhairstyles ??
              'Recommended Hairstyles',
          items: List<String>.from(data['hairstyles'] ?? []),
          gender: data['gender'] ?? 'man',
        ),
      ],
    );
  }

  Widget _buildHairstyleList({
    required String title,
    required List<String> items,
    required String gender,
  }) {
    final isFemale =
        gender.toLowerCase().contains('woman') ||
        gender.toLowerCase().contains('female');
    final Map<String, String> styleMap = isFemale
        ? HairstyleData.femaleHairstyles
        : HairstyleData.maleHairstyles;

    return Container(
      width: double.infinity,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(
                text: title,
                fontSize: 45,
                textColor: Colors.white,
                fontFamily: 'medium',
                width: 700,
                align: TextAlign.start,
                maxline: 1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 350.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(width: 50.w),
              itemBuilder: (context, index) {
                String styleName = items[index];

                String? assetPath = styleMap[styleName];

                if (assetPath == null) {
                  final matchingKey = styleMap.keys.firstWhere(
                    (k) => k.toLowerCase() == styleName.toLowerCase(),
                    orElse: () => '',
                  );
                  if (matchingKey.isNotEmpty) {
                    assetPath = styleMap[matchingKey];
                    styleName = matchingKey; // correct display name
                  }
                }

                if (assetPath == null) {
                  // Fallback for unknown styles - just show text chip
                  return Chip(
                    label: Text(styleName),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black12),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    AdsSplashUtils.onShowAds(context, () {
                      AppNavigation.NavigationPushReplacement(
                        context,
                        HairStyleChanger(hairStyle: styleName),
                      );
                    });
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: 250.w,
                          child: Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error));
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      CustomText(
                        text: styleName,
                        fontSize: 35,
                        textColor: Colors.white,
                        fontFamily: 'regular',
                        width: 200,
                        maxline: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
