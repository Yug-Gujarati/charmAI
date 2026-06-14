import 'package:charmai/utils/custom_text.dart';
import 'package:charmai/utils/custome_buttom.dart';
import 'package:charmai/utils/navigation.dart';
import 'package:charmai/utils/theme.dart';
import 'package:charmai/view/dating_redy_image.dart';
import 'package:charmai/view/face_analyzer.dart';
import 'package:charmai/view/face_buty_enhance.dart';
import 'package:charmai/view/virtual_try_on_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../ads/ads_init_utils.dart';
import '../l10n/app_localizations.dart';
import '../models/option_model.dart';
import 'custom_face_swap.dart';
import 'hair_style_changer.dart';


class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {

  List<optionModel> getTools(BuildContext context) {
    return [
      optionModel(
        title: AppLocalizations
            .of(context)
            ?.aidatingimage ?? 'AI Dating Tool',
        image: 'assets/home/dating.webp',
        description: 'Create perfect profile pics',
        screen: const DatingRedyImage(),
      ),
      optionModel(
        title: AppLocalizations
            .of(context)
            ?.faceSwap ??'FacesWap',
        image: 'assets/home/face_swape.webp',
        description: 'AI-Powered Face Transformations',
        screen: const CustomFaceSwap(),
      ),
      optionModel(
        title: AppLocalizations
            .of(context)
            ?.chagehairstyle ??'Hairstyle Change',
        image: 'assets/home/hair.webp',
        description: 'Try 100+ Hairstyle Instantly',
        screen: const HairStyleChanger(),
      ),
      optionModel(
        title: AppLocalizations
            .of(context)
            ?.virtualtryon ??'Cloth Chanager',
        image: 'assets/home/cloth.webp',
        description: 'Change outfits with AI',
        screen: const VirtualTryOnScreen(),
      ),
      optionModel(
        title: AppLocalizations
            .of(context)
            ?.suggesthairstyle ??'AI Hair Suggest',
        image: 'assets/home/face_analyze.webp',
        description: 'Find your perfect look',
        screen: const FaceAnalyzer(),
      ),
      optionModel(
        title: AppLocalizations
            .of(context)
            ?.facebeauty ??'Face Beauty',
        image: 'assets/home/face_buty.webp',
        description: 'Enhance features naturally',
        screen: const FaceButyEnhance(),
      ),
    ];
  }

    @override
    Widget build(BuildContext context) {
      final tools = getTools(context);

      return Container(
        color: AppColors.mainAppBackground,
        child: Padding(
          padding:  EdgeInsets.only( left: 50.w, right: 50.w, ),
          child: GridView.builder(
            primary: false,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 5,
              childAspectRatio: 0.9,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              return _buildToolCard(tools[index]);
            },
          ),
        ),
      );
    }

    Widget _buildToolCard(optionModel tool) {
      return CustomeButtomWithImage(
          height: 150.h,
          width: 300.w,
          image:   tool.image,
          onTap: (){
            AdsSplashUtils.onShowAds(context, () {
              AppNavigation.NavigationPush(context, tool.screen);
            });
          },
          isShowAd: false,
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomText(
                    text: tool.title,
                    fontSize: 45,
                    textColor: AppColors.primaryText,
                    width: 350,
                    fontFamily: 'regular',
                    maxline: 2,
                    align: TextAlign.center

                ),
                // Text(
                //   tool.title,
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(
                //     color: Colors.white,
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                IgnorePointer(
                  child: CustomeButtomWithImageFit(
                      height: 60.h,
                      width: 300.w,
                      image: "assets/change_hair_style/button.png",
                      onTap: (){},
                      isShowAd: false,
                      child: Center(
                        child: CustomText(
                          text: AppLocalizations.of(context)?.tryNow ??"Try Now",
                          fontSize: 45,
                          textColor: AppColors.buttonText,
                          width: 250,
                          maxline: 1,
                          align: TextAlign.center,
                        ),
                      )
                  ),
                )
              ],
            ),
          ));
    }
  }