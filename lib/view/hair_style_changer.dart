import 'package:charmai/view/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
import 'package:provider/provider.dart';

import '../view_model/hair_style_changer_provider.dart';
import '../view_model/image_picker_provider.dart';
import 'coin_purchase_screen.dart';


class HairStyleChanger extends StatefulWidget {
  final String? hairStyle;
  const HairStyleChanger({super.key, this.hairStyle});

  @override
  State<HairStyleChanger> createState() => _HairStyleChangerState();
}

class _HairStyleChangerState extends State<HairStyleChanger> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_HAIRSTYLE_SCREEN");

    if (widget.hairStyle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeSelection();
      });
    }

    super.initState();
  }


  int currentCoins = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeSelection() {
    final provider = context.read<HairStyleChangerProvider>();
    final style = widget.hairStyle!;

    bool isFemale = HairstyleData.femaleHairstyles.containsKey(style);
    bool isMale = HairstyleData.maleHairstyles.containsKey(style);

    if (isFemale) {
      provider.setGender(true);
    } else if (isMale) {
      provider.setGender(false);
    } else {
      final femaleKey = HairstyleData.femaleHairstyles.keys.firstWhere(
            (k) => k.toLowerCase() == style.toLowerCase(),
        orElse: () => '',
      );
      if (femaleKey.isNotEmpty) {
        provider.setGender(true);
      } else {
        provider.setGender(false);
      }
    }

    provider.setHairStyle(style);

    final styles = provider.currentHairstyles.keys.toList();
    int index = styles.indexWhere(
          (k) => k.toLowerCase() == style.toLowerCase(),
    );

    if (index != -1) {
      double offset = index * 320.w;

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }


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
                context.read<HairStyleChangerProvider>().clearResults();
                context.read<ImagePickerProvider>().clearImage();
                AdsSplashUtils.onShowAds(context, () {
                  AppNavigation.NavigationBack(context);
                });
              },
              name: AppLocalizations.of(context)?.chagehairstyle ??"Change Hair Style",
              showPremium: true,
            ),

            Expanded(
              child: Consumer2<HairStyleChangerProvider, ImagePickerProvider>(
                builder: (context, hairStyleProvider, imageEditorProvider, child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        vSpace(20.h),
                        CustomImageSelectionCard(
                          originalImage: imageEditorProvider.selectedImage,
                          generatedImage: hairStyleProvider.resultImageUrl,
                          onTap: () {
                             imageEditorProvider.pickImage();
                          },
                          isLoading: hairStyleProvider.isLoading,
                        ),

                        SizedBox(height: 24.h),

                        // Gender Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: hairStyleProvider.isLoading
                                  ? null
                                  : () => hairStyleProvider.setGender(
                                !hairStyleProvider.isFemale,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 180.w,
                                height: 70.h,
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80.r),
                                  gradient: LinearGradient(
                                    colors: hairStyleProvider.isFemale
                                        ? const [
                                      Color(0xFFF48FB1), // Female — pink
                                      Color(0xFFF48FB1),
                                    ]
                                        : const [
                                      Color(0xFF4FC3F7), // Male — blue
                                      Color(0xFF4FC3F7),
                                    ],
                                  ),
                                ),
                                child: Align(
                                  alignment: hairStyleProvider.isFemale
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 80.r,
                                    height: 80.r,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Image.asset(
                                        hairStyleProvider.isFemale
                                            ? "assets/change_hair_style/female_icon.png"
                                            : "assets/change_hair_style/male_icon.png",
                                        color: hairStyleProvider.isFemale
                                            ? const Color(0xFFF48FB1)
                                            : const Color(0xFF4FC3F7),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        SizedBox(
                          height: 350.h,
                          child: ListView.separated(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount:
                            hairStyleProvider.currentHairstyles.length,

                            separatorBuilder: (context, index) =>
                                SizedBox(width: 20.w),
                            itemBuilder: (context, index) {
                              String key = hairStyleProvider
                                  .currentHairstyles
                                  .keys
                                  .elementAt(index);
                              String assetPath =
                              hairStyleProvider.currentHairstyles[key]!;
                              bool isSelected =
                                  hairStyleProvider.selectedHairStyle == key;

                              return GestureDetector(
                                onTap: hairStyleProvider.isLoading
                                    ? null
                                    : () => hairStyleProvider.setHairStyle(key),
                                child: Container(
                                  width: 300.w,
                                  height: 350.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryText
                                          : AppColors.transparent,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                        const BorderRadius.vertical(
                                          top: Radius.circular(10),
                                        ),
                                        child: Image.asset(
                                          assetPath,
                                          fit: BoxFit.cover,
                                          height: 280.h,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.error),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 15.h,
                                        left: 0,
                                        right: 0,

                                        child: CustomText(
                                          text: key,
                                          fontSize: 30,
                                          textColor: isSelected
                                              ? AppColors.primaryText
                                              : AppColors.secondaryText,
                                          fontFamily: isSelected
                                              ? 'medium'
                                              : 'regular',
                                          width: 200,
                                          align: TextAlign.center,
                                          maxline: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 40.h),

                        SizedBox(
                          height: 120.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: hairStyleProvider.hairColors.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              String key = hairStyleProvider.hairColors.keys
                                  .elementAt(index);
                              String assetPath =
                              hairStyleProvider.hairColors[key]!;
                              bool isSelected =
                                  hairStyleProvider.selectedHairColor == key;

                              return GestureDetector(
                                onTap: hairStyleProvider.isLoading
                                    ? null
                                    : () => hairStyleProvider.setHairColor(key),
                                child: Container(
                                  width: 150.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryText
                                          : AppColors.transparent,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.w),
                                          child: ClipOval(
                                            child: Image.asset(
                                              assetPath,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        Consumer<CoinProvider>(
                          builder: (context, value, child) {
                            return CustomeButtomWithImage(
                              height: 130.h,
                              width: 950.w,
                              image: "assets/change_hair_style/button.png",
                              onTap: () {
                                if(hairStyleProvider.isLoading){
                                  showToast("Image generation is in progress, please wait");
                                }
                                else if (imageEditorProvider.selectedImage == null) {
                                  showToast("Please pick image of face");
                                } else {
                                  if (value.coins >=
                                      AdsVariable
                                          .ca_reduce_coin_on_ai_lab_api) {
                                    hairStyleProvider.generateTaskId(
                                      imageEditorProvider.selectedImage!,
                                      hairStyleProvider.selectedHairStyle,
                                      context,
                                      color:
                                      hairStyleProvider.selectedHairColor,
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
                                            hairStyleProvider.generateTaskId(
                                              imageEditorProvider
                                                  .selectedImage!,
                                              hairStyleProvider
                                                  .selectedHairStyle,
                                              context,
                                              color: hairStyleProvider
                                                  .selectedHairColor,
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
                                              hairStyleProvider.generateTaskId(
                                                imageEditorProvider
                                                    .selectedImage!,
                                                hairStyleProvider
                                                    .selectedHairStyle,
                                                context,
                                                color: hairStyleProvider
                                                    .selectedHairColor,
                                              );
                                            } else {
                                              _fetchCoins();
                                            }
                                          },
                                              () {
                                            AppNavigation.NavigationBack(context);
                                            hairStyleProvider.generateTaskId(
                                              imageEditorProvider
                                                  .selectedImage!,
                                              hairStyleProvider
                                                  .selectedHairStyle,
                                              context,
                                              color: hairStyleProvider
                                                  .selectedHairColor,
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
                                                hairStyleProvider
                                                    .generateTaskId(
                                                  imageEditorProvider
                                                      .selectedImage!,
                                                  hairStyleProvider
                                                      .selectedHairStyle,
                                                  context,
                                                  color: hairStyleProvider
                                                      .selectedHairColor,
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
                                    text: AppLocalizations.of(context)?.chagehairstyle ??"Change Hairstyle",
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
