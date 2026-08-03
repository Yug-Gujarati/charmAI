import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ads/AdsVariable.dart';
import '../ads/ads_loading_util.dart';
import '../ads/analytics_service.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/app_constants.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/theme.dart';
import 'intro_screen.dart';

class LanguagePage extends StatefulWidget {
  final bool isFromHomeScreen;
  const LanguagePage({super.key, required this.isFromHomeScreen});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? _selectedLanguage;
  bool isPresed = false;
  bool isPresedButton = false;
  bool? isFirstLaunch;

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    showLog("language page isFirstLaunch $isFirstLaunch");

    setState(() {
      isFirstLaunch = firstLaunch;
      if (!firstLaunch && widget.isFromHomeScreen) {
        _selectedLanguage = prefs.getString('selectedLanguage');
      }
    });
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? '';
    });
    // if (firstLaunch) {
    //   AdsVariable.introFullAd  = await NativeAdIntroService().loadNativeAdIntro(AdsVariable.cs_full_nativeAd);
    //   // NativeAdIntroService2.loadNativeAdIntro2(AdsVariable.sg_full_nativeAd2);
    // }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {

      showLog("this is native ad ${AdsVariable.languageAd}");
      showLog("this is is from home ${widget.isFromHomeScreen}");

      if (AdsVariable.languageAd == null && widget.isFromHomeScreen == true) {
        showLog("Language is null");
        AdsVariable.languageAd = await AdsLoadUtil().loadNative(AdsVariable.ca_language_nativeAd, false);
        showLog("first Language is null after");
      } else {
        showLog("Language is not null");
      }
      setState(() {

      });

    });
    _checkFirstLaunch(); // Initialize the isFirstLaunch variable
    _loadSelectedLanguage();
    _initializeLanguageSettings();
    FirebaseAnalyticsService.logEvent(eventName: "CA_LANGUAGE_SCREEN");
  }

  @override
  void dispose() {
    AdsVariable.languageAd?.dispose();
    AdsVariable.languageAd = null;
    AdsLoadUtil.isNativeAdLoaded.value = false;

    showLog("Call Dispose");
    super.dispose();
  }

  Future<void> _selectLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _initializeLanguageSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    showLog("language page $isFirstLaunch");

    setState(() {
      isFirstLaunch = firstLaunch;
      if (!firstLaunch || widget.isFromHomeScreen) {
        _selectedLanguage = prefs.getString('selectedLanguage');
      }
    });
  }

  Future<void> _navigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    } else {
      if (widget.isFromHomeScreen) {
        Navigator.pop(context);
      }
    }
  }

  void _changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);

    MyApp.setLocale(context, locale);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', _selectedLanguage!);

    _navigate();
  }

  final Map<String, String> _languageCodes = {
    'English': 'en',
    'Spanish': 'es',
    'German': 'de',
    'French': 'fr',
    'Arabic': 'ar',
    'Russian': 'ru',
    'Hindi': 'hi',
    'Portuguese': 'pt',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Chinese': 'zh',
    'Turkish': 'tr',
    'Dutch': 'nl',
    'Vietnamese': 'vi',
    //'Indonesian': 'id',
    'Thai': 'th',
    'Malaysian': 'ms',
    'Punjabi': 'pa',
  };

  final List<Map<String, String>> _languages = [
    {
      'icon': 'assets/language/english.png',
      'name': 'English',
      'nativeName': '(English)'
    },
    {
      'icon': 'assets/language/spanish.png',
      'name': 'Spanish',
      'nativeName': '(Español)'
    },
    {
      'icon': 'assets/language/german.png',
      'name': 'German',
      'nativeName': '(Deutsch)'
    },
    {
      'icon': 'assets/language/french.png',
      'name': 'French',
      'nativeName': '(Français)'
    },
    {
      'icon': 'assets/language/arabic.png',
      'name': 'Arabic',
      'nativeName': '(العربية)'
    },
    {
      'icon': 'assets/language/russian.png',
      'name': 'Russian',
      'nativeName': '(Русский)'
    },
    {
      'icon': 'assets/language/hindi.png',
      'name': 'Hindi',
      'nativeName': '(हिन्दी)'
    },
    {
      'icon': 'assets/language/portuguese.png',
      'name': 'Portuguese',
      'nativeName': '(Português)'
    },
    {
      'icon': 'assets/language/japanese.png',
      'name': 'Japanese',
      'nativeName': '(日本語)'
    },
    {
      'icon': 'assets/language/korean.png',
      'name': 'Korean',
      'nativeName': '(한국어)'
    },
    {
      'icon': 'assets/language/chinese.png',
      'name': 'Chinese',
      'nativeName': '(中文)'
    },
    {
      'icon': 'assets/language/turkish.png',
      'name': 'Turkish',
      'nativeName': '(Türkçe)'
    },
    {
      'icon': 'assets/language/dutch.png',
      'name': 'Dutch',
      'nativeName': '(Nederlands)'
    },
    {
      'icon': 'assets/language/vietnamese.png',
      'name': 'Vietnamese',
      'nativeName': '(Tiếng Việt)'
    },
    // {
    //   'icon': 'assets/newdesign/langauge/indonesian.png',
    //   'name': 'Indonesian',
    //   'nativeName': '(Bahasa Indonesia)'
    // },
    {
      'icon': 'assets/language/thai.png',
      'name': 'Thai',
      'nativeName': '(ไทย)'
    },
    {
      'icon': 'assets/language/malaysian.png',
      'name': 'Malaysian',
      'nativeName': '(Bahasa Melayu)'
    },
    {
      'icon': 'assets/language/punjabi.png',
      'name': 'Punjabi',
      'nativeName': '(ਪੰਜਾਬੀ)'
    },
  ];

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            height: 1920.h,
            width: 1080.w,

            child: Stack(
              children: [
                Positioned(
                  top: 0.h,
                  left: 0.w,
                  right: 0.w,
                  bottom: 0.w,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 200.h, bottom: 50.h, left: 50.w, right: 50.w),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected =
                          _selectedLanguage == language['name'];
                      final imagePath = isSelected
                          ? 'assets/language/select_new.png'
                          : 'assets/language/unbselect.png';
                      final icon = language['icon'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLanguage = language['name'];
                          });
                        },
                        child: Container(
                          height: 140.h,
                          width: 700.w,
                          margin: EdgeInsets.only(top: 10, ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(imagePath),
                                fit: BoxFit.fill),
                          ),

                          child: Padding(
                            padding: EdgeInsets.only(right: 50.w),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 50.w,
                                  ),
                                  child: Container(
                                    width: 130.w,
                                    height: 90.h,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      image: DecorationImage(
                                          image: AssetImage(icon!),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20.w),

                                Text(
                                  language['name']!,
                                  style: TextStyle(
                                    fontFamily: "sregular",
                                    color: Colors.white,
                                    fontSize: 45.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w,),
                                SizedBox(
                                  width: 350.w,
                                  child: Text(
                                    language['nativeName']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: "sregular",
                                      color: Colors.white,
                                      fontSize: 45.sp,
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.r),
                    bottomRight: Radius.circular(30.r),
                  ),
                  child: SizedBox(
                    width: 1080.w,
                    height: 200.h,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.only(top: 100.h, left: 50.w, right: 50.w),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (isFirstLaunch != null && !isFirstLaunch!)

                              CustomeButtomWithImage(
                                  height: 100.h,
                                  width: 100.w,
                                  isShowAd: false,
                                  image: "assets/language/back.png",
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container()),
                            Spacer(),
                            CustomText(
                              text: AppLocalizations.of(context)?.selectelanguage ??
                                  "Select Your Language",
                              fontSize: 50,
                              textColor: AppColors.primaryText,
                              fontFamily: "bold",
                              width: 700,
                              maxline: 1,
                              align: TextAlign.center,
                            ),

                            Spacer(),
                            Visibility(
                              visible: _selectedLanguage != '',
                              child: CustomeButtomWithImage(
                                height: 100.h,
                                width: 100.w,
                                isShowAd: false,
                                image: "assets/language/done.png",
                                onTap: () {
                                  if (_selectedLanguage!.isNotEmpty) {
                                    final localeCode =
                                    _languageCodes[_selectedLanguage!];
                                    _changeLanguage(localeCode!);
                                    showLog(
                                        'Selected Language Codes: $localeCode');
                                  } else {
                                    showLog('No language selected');
                                  }
                                },
                                child: Container(),
                              ),
                            ),
                            SizedBox(
                              width: 20.w,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _selectedLanguage == '',
                  child: Positioned(
                      top: 100,
                      right: 30,
                      child: Image.asset("assets/language/click22.gif", height: 100.h )),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
          (AdsVariable.ca_language_nativeAd != "11")
              ? NativeAdsWidget(
              showNativeAd: AdsVariable.languageAd,
              isSmallNative: false)
              : Container(
            height: 0,
          )
      ),
    );
  }
}
