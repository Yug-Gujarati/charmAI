
import 'package:charmai/utils/app_constants.dart';
import 'package:charmai/view/bottom_nav_bar_screen.dart';
import 'package:charmai/view/face_buty_enhance.dart';
import 'package:charmai/view/splash_screen.dart';
import 'package:charmai/view/virtual_try_on_screen.dart';
import 'package:charmai/view_model/category_provider.dart';
import 'package:charmai/view_model/coin_managment.dart';
import 'package:charmai/view_model/custom_face_swap_provider.dart';
import 'package:charmai/view_model/dating_redy_image_provider.dart';
import 'package:charmai/view_model/face_analyzer_provider.dart';
import 'package:charmai/view_model/face_buty_provider.dart';
import 'package:charmai/view_model/face_swap_provider.dart';
import 'package:charmai/view_model/hair_style_changer_provider.dart';
import 'package:charmai/view_model/image_generation_provider.dart';
import 'package:charmai/view_model/image_picker_provider.dart';
import 'package:charmai/view_model/premium_provider_screen.dart';
import 'package:charmai/view_model/subprise_provider.dart';
import 'package:charmai/view_model/virtual_try_on_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ads/AppLifeReactor.dart';
import 'ads/appOpenAdManager.dart';
import 'l10n/app_localizations.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await MobileAds.instance.initialize();
  showLog("this is after mobile ads initlize");
  final localeCode = prefs.getString('locale') ?? 'en';
  final locale = Locale(localeCode);
  bool firstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider<ImageGenerationProvider>(
          create: (_) => ImageGenerationProvider(),
        ),
        ChangeNotifierProvider<FaceSwapProvider>(
          create: (_) => FaceSwapProvider(),
        ),
        ChangeNotifierProvider<CoinProvider>(
          create: (_) => CoinProvider(),
        ),
        ChangeNotifierProvider<HairStyleChangerProvider>(
          create: (_) => HairStyleChangerProvider(),
        ),
        ChangeNotifierProvider<ImagePickerProvider>(
          create: (_) => ImagePickerProvider(),
        ),
        ChangeNotifierProvider<VirtualTryOnProvider>(
          create: (_) => VirtualTryOnProvider(),
        ),
        ChangeNotifierProvider<FaceBeautyProvider>(
          create: (_) => FaceBeautyProvider(),
        ),
        ChangeNotifierProvider<FaceAnalyzerProvider>(
          create: (_) => FaceAnalyzerProvider(),
        ),
        ChangeNotifierProvider<CustomFaceSwapProvider>(
          create: (_) => CustomFaceSwapProvider(),
        ),
        ChangeNotifierProvider<DatingRedyImageProvider>(
          create: (_) => DatingRedyImageProvider(),
        ),
        ChangeNotifierProvider<PremiumProvider>(
          create: (_) => PremiumProvider(),
        ),
        ChangeNotifierProvider<SubpriseProvider>(
          create: (_) => SubpriseProvider(),
        ),

      ],
      child: MyApp(initialLocale: locale),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(locale); // Method to update the locale
  }
}

class _MyAppState extends State<MyApp> {
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;
  Locale? _locale;

  @override
  void initState() {
    print("this is main screen log");
    super.initState();
    _locale = widget.initialLocale;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appLifecycleReactor = AppLifecycleReactor(
        appOpenAdManager: appOpenAdManager,
      );
      _appLifecycleReactor.listenToAppStateChanges();
    });
  }

  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode); // Save the new locale
    Get.updateLocale(locale);
    setState(() {
      _locale = locale; // Update the locale
    });
  }


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),

      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CharmAI',
        locale: _locale,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        home: SplashScreen(),//BottomNavBarScreen(),
      ),
    );
  }
}


