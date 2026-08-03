
import 'package:charmai/view/premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../ads/AdsVariable.dart';
import '../ads/ads_loading_util.dart';
import '../ads/analytics_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/navigation.dart';
import '../utils/theme.dart';
import '../view_model/coin_managment.dart';
import '../utils/custom_image_compare_slider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final bool _isPressed = false;

  //String adId = AdsVariable.wu_intro_bannerAd;
  final bool _isNativeAdLoaded = false;
  //bool _isSecondNativeAdLoaded = false;
  bool failedToLoad = false;
  bool failedToLoad2 = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showLog("this is native ad $_isNativeAdLoaded");
      _checkFirstLaunch();
    });

    FirebaseAnalyticsService.logEvent(eventName: "CA_INTRO_SCREEN");
  }

  Future<void> _checkFirstLaunch() async {
    await context.read<CoinProvider>().createNewStore();

    if (!mounted) return;

    String deviceId = await context.read<CoinProvider>().getRandomId();

    int? updatedCoins = await context.read<CoinProvider>().getCoins(deviceId);

    if (updatedCoins != null) {
      showLog("User awarded $updatedCoins credits for first launch.");
    } else {
      showLog("Failed to fetch the updated coins for the user.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                Intro(
                  title: AppLocalizations.of(context)?.intro1title ??"Create Your Perfect Dating Look",
                  description:
                  AppLocalizations.of(context)?.intro1description ??"Generate stunning AI dating photos that make you stand out. Create attractive, natural-looking profile pictures designed to boost your confidence and matches.",
                  image: "assets/intro/intro_22.webp",
                  button: "assets/intro/next_pressed.png",
                  pageController: _pageController,
                  currentPage: _currentPage,
                  isNativeloaded: _isNativeAdLoaded,
                ),
                Intro(
                  title: AppLocalizations.of(context)?.intro2title ??"Create Professional AI Headshots",
                  description:
                  AppLocalizations.of(context)?.intro2description ??"Turn your selfies into studio-quality professional headshots for LinkedIn, resumes, business profiles, and social media — all powered by AI.",
                  image: "assets/intro/intro_11.webp",
                  button: "assets/intro/next_pressed.png",
                  pageController: _pageController,
                  currentPage: _currentPage,
                  isNativeloaded: _isNativeAdLoaded,
                ),
                if (AdsLoadUtil.isNativeIntroAdLoaded.value)
                  NativeIntroAdsWidget(showNativeAd: AdsVariable.introFullAd!),
                Intro(
                  title: AppLocalizations.of(context)?.intro3title ??"Try Hairstyles & Outfits Instantly",
                  description:
                  AppLocalizations.of(context)?.intro3description ??"Explore trendy hairstyles and virtual outfit changes tailored to your face and style. Discover the perfect look before making any real changes.",
                  image: "assets/intro/intro_33.webp",
                  button: "assets/intro/next_pressed.png",
                  pageController: _pageController,
                  currentPage: _currentPage,
                  isNativeloaded: _isNativeAdLoaded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Intro extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final String button;
  final PageController pageController;
  final int currentPage;
  final bool isNativeloaded;

  const Intro({
    super.key,
    required this.title,
    required this.description,
    required this.pageController,
    required this.currentPage,
    required this.isNativeloaded,
    required this.image,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    bool isAdLoaded = AdsLoadUtil.isNativeIntroAdLoaded.value;

    int totalIntroPages = 3;

    int adjustedPage = currentPage;

    if (isAdLoaded) {
      if (currentPage > 2) {
        adjustedPage = 2;
      } else if (currentPage == 2) {
        adjustedPage = -1;
      }
    }
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Top Section: Image or Slider
          Expanded(
            child: Container(
              width: 1080.w,
              height: 900.h,
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Stack(
                children: [
                    Container(
                      height: 900.h,
                      child: Image.asset(image, fit: BoxFit.cover,)
                    ),
                  Positioned(
                    bottom: 50.h,
                    child: Container(
                      width: 1080.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          end: Alignment.bottomCenter,
                            begin: Alignment.topCenter,
                            colors: [
                          Colors.transparent,
                          Colors.black
                        ])
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),

          // Bottom Section: Text and Controls
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                    CustomText(
                      text: title,
                      fontSize: 70,
                      fontFamily: 'bold',
                      width: 900,
                      textColor: AppColors.primaryText,
                      maxline: 2,
                      align: TextAlign.center,
                    ),

                  SizedBox(height: 30.h),
                  // Description
                  CustomText(
                    text: description,
                    fontSize: 40,
                    fontFamily: 'regular',
                    width: 1000,
                    textColor: AppColors.secondaryText,
                    maxline: 5,
                    align: TextAlign.center,
                  ),

                  SizedBox(height: 150.h,),

                  Padding(
                    padding: EdgeInsets.only(left: 100.w, right: 100.w),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.5,
                          child: SizedBox(
                            height: 100.h,
                            width: 150.w,
                            child: Image.asset(
                              'assets/intro/Flow 11@512p-25fps.gif',
                            ),
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(totalIntroPages, (index) {
                            bool isActive = index == adjustedPage;

                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              width: isActive ? 100.w : 50.w,
                              height: 20.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: isActive
                                    ? AppColors.skyBlue
                                    : Colors.grey.shade800,
                              ),
                            );
                          }),
                        )

                      ],
                    ),
                  ),


                  Spacer(),

                  CustomeButtomWithImage(
                      height: 130.h,
                      width: 950.w,
                      image: button,
                      onTap: () async {
                        if(currentPage == (AdsLoadUtil.isNativeIntroAdLoaded.value ? 3 : 2)){
                          AppNavigation.NavigationPushReplacement(context, PremiumScreen(isFromSplash: true, onDone: (){}));

                        }
                        else {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      isShowAd: false,
                      child: Container(
                        width: 275.w,
                        alignment: Alignment.center,
                        child: CustomText(
                          text:  currentPage == (isNativeloaded ? 3 : 2)
                              ? AppLocalizations.of(context)?.done ??"Done"
                              : AppLocalizations.of(context)?.next ?? "Next",
                          fontSize: 60,
                          fontFamily: 'bold',
                          width: 500,
                          textColor: AppColors.primaryText,
                          maxline: 1,
                          align: TextAlign.center,
                        ),

                      )
                  ),



                  SizedBox(height: 150.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
