import 'dart:async';
import 'dart:developer';

import 'package:charmai/view/privacy_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ads/AdsVariable.dart';
import '../ads/AppLifeReactor.dart';
import '../ads/analytics_service.dart';
import '../ads/appOpenAdManager.dart';
import '../utils/app_constants.dart';
import '../utils/constant.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/dialog.dart';
import '../utils/globalVariables.dart';
import '../utils/theme.dart';
import '../view_model/coin_managment.dart';
import '../view_model/premium_provider_screen.dart';
import 'bottom_nav_bar_screen.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';
import 'iAmTester.dart';

class PremiumScreen extends StatefulWidget {
  final bool isFromSplash;
  String? from;
  final Function onDone;
  PremiumScreen({
    super.key,
    required this.isFromSplash,
    required this.onDone,
    this.from,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int selected = 0;
  bool isPresed = false;
  bool isPresedButton = false;
  int SelectPremium = 1;
  double perweekprice = 0;
  int selectedContainer = 0;
  //bool trialEligible = false;

  Offerings? _offerings;
  bool week = false;
  bool onemonth = true;
  bool threeweek = false;
  Map<String, Package>? availablePackages;
  Map<String, Package>? packageEntry;
  Package? selectedPackage;
  int index = 0;
  int coinIndex = 0;

  bool _isCloseVisible = false;
  Package? weeklyPackage;
  //Package? yearlyPackage;
  Package? monthlyPackage;

  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    // AppLifecycleReactor appLifecycleListener =
    //     AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    // appLifecycleListener.listenToAppStateChanges(shouldShow: false);

    // _appLifecycleReactor = AppLifecycleReactor(
    //   appOpenAdManager: appOpenAdManager,
    // );
    // _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      fetchData();
      makeCloseVisible();
      showLog("AppLifecycleReactor premium Should Show false");
    });
    if (widget.isFromSplash) {
      FirebaseAnalyticsService.logEvent(
        eventName: "CA_PREMIUM_SCREEN_FROM_SPLASH",
      );
    } else {
      FirebaseAnalyticsService.logEvent(
        eventName: "CA_PREMIUM_SCREEN_FROM_FEATURE",
      );
    }

    super.initState();
  }

  void makeCloseVisible() {
    Timer(Duration(seconds: 3), () {
      setState(() {
        _isCloseVisible = true;
      });
    });
  }

  MapEntry<String, Package>? getPackageByIdentifier(String identifier) {
    if (availablePackages != null) {
      try {
        // Retrieve the MapEntry for the package by identifier
        final packageEntry = availablePackages!.entries.firstWhere(
              (entry) => entry.value.storeProduct.identifier == identifier,
        );

        return packageEntry;
      } catch (e) {
        showLog("Error retrieving package: $e");
        return null;
      }
    }
    // Return null if the availablePackages is null
    return null;
  }

  Future<void> fetchData() async {
    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();

      showLog("this is offerings $offerings");
      weeklyPackage = offerings.current!.availablePackages.firstWhere(
            (test) => test.storeProduct.identifier == AdsVariable.week_plan_identifier,
        orElse: () => throw Exception("Weekly package not found: check AdsVariable.week_plan_identifier"),
      );

      monthlyPackage = offerings.current!.availablePackages.firstWhere(
            (test) => test.storeProduct.identifier == AdsVariable.month_plan_identifier,
        orElse: () => throw Exception("Monthly package not found: check AdsVariable.month_plan_identifier"),
      );

      // yearlyPackage =
      //     offerings.current!.availablePackages
      //         .where(
      //           (test) =>
      //       test.storeProduct.identifier ==
      //           AdsVariable.year_plan_identifier,
      //     )
      //         .first;

      // monthlyPackage = offerings.current!.availablePackages
      //     .where(
      //       (test) =>
      //   test.storeProduct.identifier ==
      //       AdsVariable.month_plan_identifier,
      // )
      //     .first;

      // if (AdsVariable.ca_selected_plan == "week") {
      //   selectedPackage = weeklyPackage;
      //   index = 0;
      //   coinIndex = 0;
      // }
      // else if (AdsVariable.cs_selected_plan == "year") {
      //   selectedPackage = yearlyPackage;
      //   coinIndex = 2;
      //   index = 2;
      // }
      // else if (AdsVariable.ca_selected_plan == "month") {
      //   selectedPackage = monthlyPackage;
      //   index = 1;
      //   index = 1;
      // }
      // if (AdsVariable.sg_week_plan_selected) {
      //   selectedPackage = weeklyPackage;
      //   index = 0;
      // } else if() {
      //   selectedPackage = yearlyPackage;
      //   index = 1;
      // }

      selectedPackage = weeklyPackage;
      index = 0;
      coinIndex = 0;

      showLog("this is selected package $selectedPackage");
    } on PlatformException catch (e) {
      if (kDebugMode) {
        showLog("$e");
      }
    }
    if (!mounted) return;
    setState(() {
      _offerings = offerings;
    });
  }

  void printJson(Map<String, dynamic>? json, [int indentation = 0]) {
    json?.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        printJson(value, indentation + 2);
      }
    });
  }

  static void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black.withOpacity(0.2),
          child: Center(
            child: Transform.scale(
              scale: 2,
              child: Lottie.asset(
                "assets/premium/sparkels.json",
                height: 100.h,
              ),
            ),
          ),
        );
      },
    );
  }

  static void hideProgressDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  //For iOS
  void _getPremiumVersion() async {
    try {
      showProgressDialog(context);
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(selectedPackage!),
      );
      final customerInfo = purchaseResult.customerInfo;

      appData.entitlementIsActive =
          customerInfo.entitlements.all[entitlementKey]!.isActive;
      initPlatformState();
    } on PlatformException catch (e) {
      //Navigator.pop(context);
      hideProgressDialog(context);
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.userCancelled ?? "User cancelled",
          backgroundColor: Color(0xFF1C1D25),
        );
        if (kDebugMode) {
          showLog('User cancelled');
        }
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.youarenotallowed ??"You are not allowed to purchase",
          backgroundColor: Color(0xFF1C1D25),
        );
        showLog("You are not allowed to purchase");

        if (kDebugMode) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.usernotallowed ?? "User not allowed to purchase",
            backgroundColor: Color(0xFF1C1D25),
          );
          showLog('User not allowed to purchase');
        }
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)?.paymentispending ??"Payment is Pending",
          backgroundColor: Color(0xFF1C1D25),
        );
        showLog("Payment is Pending");

        if (kDebugMode) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)?.paymentispending ??"Payment is pending",
            backgroundColor: Color(0xFF1C1D25),
          );
          showLog('Payment is pending');
        }
      }
    }
  }

  double opacity = 1;

  Future<void> initPlatformState() async {
    final customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.all[entitlementKey] != null &&
        customerInfo.entitlements.all[entitlementKey]!.isActive == true) {
      hideProgressDialog(context);

      GlobalVariables.isPremiumUser = true;
      AdsVariable.resetAdIds();
      Provider.of<PremiumProvider>(context, listen: false).setIsPurchased(true);

      final coinProvider = Provider.of<CoinProvider>(context, listen: false);

      if (index == 0) {
        coinProvider.incrementCoins(AdsVariable.ca_week_bonus_coin);
      } else {
        coinProvider.incrementCoins(AdsVariable.ca_month_bonus_coin);
      }

      Fluttertoast.showToast(
        msg: "Your plan subscribe successfully",
        backgroundColor: Color(0xFF1C1D25),
      );
      showLog('Your plan subscribed successfully with bonus coins!');
      showLog('Your plan subscribe successfully');
      final prefs = await SharedPreferences.getInstance();
      bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      if (widget.isFromSplash == true || isFirstLaunch) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return BottomNavBarScreen();
            },
          ),
        );
        widget.onDone();
      } else {
        Navigator.pop(context);
        widget.onDone();
      }
    } else {
      hideProgressDialog(context);
      Fluttertoast.showToast(
        msg: "Failed To Purchase",
        backgroundColor: Color(0xFF1C1D25),
      );
      showLog('Failed To Purchase');
    }
  }

  final String subscriptionsUrl =
      "https://play.google.com/store/account/subscriptions";

  Future<void> _opensubscriptions() async {
    if (await canLaunch(subscriptionsUrl)) {
      await launch(subscriptionsUrl);
    } else {
      throw 'Could not launch $subscriptionsUrl';
    }
  }

  Future<bool> isFreeTrialOnPackage(Package package) async {
    if (package.storeProduct.introductoryPrice != null) {
      showLog("CURRENT PLAN HAS FREE TRIAL");
      showLog("TRIAL PACKAGE IS $package");
    } else {
      showLog("NO FREE TRIAL FOUND");
    }
    final StoreProduct product = package.storeProduct;

    Map<String, IntroEligibility> eligibilityMap =
    await Purchases.checkTrialOrIntroductoryPriceEligibility([
      product.identifier,
    ]);

    IntroEligibility? eligibility = eligibilityMap[product.identifier];

    showLog("eligible status ${eligibility?.status}");

    if (eligibility?.status ==
        IntroEligibilityStatus.introEligibilityStatusEligible) {
      showLog("User is eligible for a trial or introductory offer.");
      return true;
    } else if (eligibility?.status ==
        IntroEligibilityStatus.introEligibilityStatusIneligible) {
      showLog("User is not eligible for a trial or introductory offer.");
    } else {
      showLog("Unknown eligibility for a trial or introductory offer.");
    }
    return false;
  }

  Future<String> getRegularPrice(Package package) async {
    return package.storeProduct.priceString;
  }

  Future<String> getIntroductoryPriceOnPackage(Package package) async {
    if (package.storeProduct.introductoryPrice != null) {
      showLog("CURRENT PLAN HAS FREE TRIAL");
      showLog("TRIAL PACKAGE IS $package");
    } else {
      showLog("NO FREE TRIAL FOUND");
    }
    final StoreProduct product = package.storeProduct;

    Map<String, IntroEligibility> eligibilityMap =
    await Purchases.checkTrialOrIntroductoryPriceEligibility([
      product.identifier,
    ]);

    IntroEligibility? eligibility = eligibilityMap[product.identifier];

    showLog("eligible status ${eligibility?.status}");

    if (eligibility?.status ==
        IntroEligibilityStatus.introEligibilityStatusEligible) {
      showLog("User is eligible for a trial or introductory offer.");
      return package.storeProduct.introductoryPrice!.priceString;
    } else if (eligibility?.status ==
        IntroEligibilityStatus.introEligibilityStatusIneligible) {
      showLog("User is not eligible for a trial or introductory offer.");
    } else {
      showLog("Unknown eligibility for a trial or introductory offer.");
    }
    return '';
  }

  String calculateDiscount(Package? weekly, Package? monthly) {
    if (weekly == null || monthly == null) return "Offer";
    try {
      double weeklyPrice = weekly.storeProduct.price;
      double monthlyPrice = monthly.storeProduct.price;
      showLog("this is week price $weeklyPrice");
      showLog("this is month price $monthlyPrice");
      if (weeklyPrice <= 0 || monthlyPrice <= 0) return "Offer";

      double monthlyCostIfWeekly = weeklyPrice * 4;
      double discount =
          ((monthlyCostIfWeekly - monthlyPrice) / monthlyCostIfWeekly) * 100;


      if (discount <= 0) return "Offer";
      showLog("this is discount price $discount}");

      return "${discount.round()}% OFF";
    } catch (e) {
      return "Offer";
    }
  }

  Widget getPremiumWidget() {
    var heightof = MediaQuery.of(context).size.height;
    var widthof = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

            buildContainer(
              weeklyPackage!,
              0,
              0,
              AppLocalizations.of(context)?.weekly ?? "Weekly",
              "Pay for 1 week",
            ),
            SizedBox(height: 50.h),
            buildContainer(
              monthlyPackage!,
              1,
              1,
              AppLocalizations.of(context)?.monthly ?? "Monthly",
              "Pay for 1 month",
            ),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (coinIndex == 0)
                CustomText(
                  text: "${AdsVariable.ca_week_bonus_coin} ${AppLocalizations.of(context)?.bonuscredit ?? "bonus credit"} ",
                  fontSize: 45,
                  fontFamily: 'regular',
                  textColor: Colors.white,
                  width: 650,
                  maxline: 1,
                  align: TextAlign.end,
                )

              else if(coinIndex == 1)
                CustomText(
                  text: "${AdsVariable.ca_month_bonus_coin} ${AppLocalizations.of(context)?.bonuscredit ?? "bonus credit"} ",
                  fontSize: 45,
                  fontFamily: 'regular',
                  textColor: Colors.white,
                  width: 650,
                  maxline: 1,
                  align: TextAlign.end,
                ),

              Lottie.asset("assets/premium/Gift.json", )

            ],
          ),
          Visibility(
            visible: !(widget.from == "home" || widget.isFromSplash),
            child: TextButton(
              onPressed: () {
                showLog("this is testter method");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Iamtestr(
                      onDone: () async {
                        showLog("i am tester log");
                        await widget.onDone();
                      },
                    ),
                  ),
                );
              },
              child: CustomText(
                text: "I Am Tester",
                fontSize: 50,
                fontFamily: 'bold',
                textColor: Colors.white,
                width: 700,
                maxline: 1,
                align: TextAlign.center,
              ),
            ),
          ),

          CustomeButtomWithImage(
            width: 950.w,
            height: 150.h,
            isShowAd: false,
            image: "assets/intro/next_pressed.png",
            onTap: () {
              _getPremiumVersion();
            },
            child: Center(
              child: CustomText(
                text: AppLocalizations.of(context)?.continuee ?? "Continue",
                fontSize: 60,
                textColor: AppColors.buttonText,
                fontFamily: 'bold',
                width: 600,
                maxline: 1,
                align: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          height: 1920.h,
          width: 1080.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 850.h,
                  width: 1080.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/premium/coin_image.webp"),
                      fit: BoxFit.fill,
                    ),
                  ),

                  child: Stack(

                    children: [
                      Positioned(
                        top: 100.h,
                        right: 10.w,
                        child: Row(
                          children: [
                            Visibility(
                              visible: _isCloseVisible,
                              child: CustomeButtomWithImage(
                                height: 100.h,
                                width: 100.w,
                                isShowAd: false,
                                image: "assets/premium/cancle.png",
                                onTap: () async {
                                  final prefs =
                                  await SharedPreferences.getInstance();
                                  prefs.setBool('isFirstLaunch', false);
                                  _appLifecycleReactor = AppLifecycleReactor(
                                    appOpenAdManager: appOpenAdManager,
                                  );
                                  _appLifecycleReactor.listenToAppStateChanges(
                                    shouldShow: true,
                                  );
                                  if (widget.isFromSplash) {
                                    showLog("this is press bottom");
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BottomNavBarScreen(),
                                      ),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(),
                              ),
                            ),
                            SizedBox(width: 70.w),
                          ],
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 1080.w,
                          height: 300.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 0,
                        right: 0,
                        child: CustomText(
                          text:
                          AppLocalizations.of(context)?.upgradeToPremium ??
                              "Upgrade To Premium",
                          fontSize: 70,
                          textColor: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          shadowsColor: Color(0xFFF090FF).withOpacity(0.6),
                          blurRadius: 20,
                          width: 500,
                          maxline: 1,
                          align: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.w,),
                Padding(
                  padding: EdgeInsets.only(left: 80.w),
                  child: Column(
                    children: [

                      SizedBox(height: 20.w,),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 50.w,),
                          hSpace(20.w),
                          CustomText(
                              text: AppLocalizations.of(context)?.generatePremium ??"Generate Premium AI Dating Photos",
                              fontSize: 35,
                              textColor: Colors.white,
                              fontFamily: 'regular',
                              width: 800,
                              maxline: 1
                          )
                        ],
                      ),
                      vSpace(20.h),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 50.w,),
                          hSpace(20.w),
                          CustomText(
                              text: AppLocalizations.of(context)?.createprofetional ??"Create Professional AI Headshots",
                              fontSize: 35,
                              textColor: Colors.white,
                              fontFamily: 'regular',
                              width: 800,
                              maxline: 1
                          )
                        ],
                      ),
                      vSpace(20.h),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 50.w,),
                          hSpace(20.w),
                          CustomText(
                              text: AppLocalizations.of(context)?.creditneveexpire ??"Credit never expire",
                              fontSize: 35,
                              textColor: Colors.white,
                              fontFamily: 'regular',
                              width: 800,
                              maxline: 1
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                Container(
                  alignment: Alignment.center,

                  child: Stack(
                    children: [
                      selectedPackage != null
                          ? getPremiumWidget()
                          : Container(
                        height: 500.h,
                            child: Transform.scale(
                               scale: 0.5,
                              child: Lottie.asset(
                                "assets/premium/sparkels.json",
                                height: 20.h,
                              ),
                            ),
                          ),

                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 280.w,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PrivacyPolicyPage('privacy'),
                            ),
                          );
                        },
                        child: CustomText(
                          text:
                          AppLocalizations.of(context)?.privacypolicy ??
                              "Privacy Policy",
                          fontSize: 35,
                          textColor: AppColors.primaryText,
                          fontFamily: 'regular',
                          width: 650,
                          maxline: 1,
                        ),
                      ),
                    ),
                    Container(height: 60.h, width: 5.w, color: Colors.white),
                    Container(
                      width: 340.w,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          _opensubscriptions();
                        },
                        child: CustomText(
                          text:
                          AppLocalizations.of(context)?.subscription ??
                              "Subscription",
                          fontSize: 35,
                          textColor: AppColors.primaryText,
                          fontFamily: 'regular',
                          width: 650,
                          maxline: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContainer(
      Package packageEntry,
      int setIndex,
      int myIndex,
      String title,
      String Description,
      ) {
    int currentIndex = 0;
    List<MapEntry<String, Package>> entries =
        availablePackages?.entries.toList() ?? [];

    final priceUnit = packageEntry.storeProduct.priceString[0];
    final perWeekPrice = myIndex == 1
        ? ((packageEntry.storeProduct.price ?? 0) / 52).toStringAsFixed(2)
        : packageEntry.storeProduct.price.toStringAsFixed(2);
    showLog("PER WEEK $perWeekPrice");

    String introductoryPrice = "0";

    introductoryPrice =
        packageEntry.storeProduct.introductoryPrice?.priceString ?? "0";
    showLog("INTRO PRICE IS $introductoryPrice");

    return GestureDetector(
      onTap: () {
        setState(() {
          index = setIndex;
          coinIndex = index;
          selectedPackage = packageEntry;
        });
      },
      child: Opacity(
        opacity: index == myIndex ? 1 : 1,
        child: Container(
          width: 1000.w,
          height: 150.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                index == myIndex
                    ? "assets/premium/monthly.png"
                    : "assets/premium/unpressed_bg.png",
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 10.h, right: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 50.w),

                CustomText(
                  text: title,
                  fontSize: 50,
                  fontFamily: "bold",
                  textColor: Colors.white,
                  width: 350,
                  align: TextAlign.start,
                  maxline: 1,
                ),
                Spacer(),

                Container(
                  width: 270.w,
                  height: 100.h,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      packageEntry.storeProduct.priceString ?? "\$ 00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50.sp,
                        fontFamily: "regular",
                      ),
                    ),
                  ),
                ),

                // Text(
                //   Description,
                //   style: TextStyle(
                //     fontSize: 30.sp,
                //     fontFamily: "medium",
                //     color: Colors.white,
                //   ),
                // ),
                SizedBox(width: 20.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
