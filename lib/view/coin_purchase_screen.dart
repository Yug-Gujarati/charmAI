import 'dart:async';


import 'package:charmai/view/privacy_policy.dart';
import 'package:flutter/cupertino.dart';
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
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/constant.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/dialog.dart';
import '../utils/globalVariables.dart';
import '../utils/theme.dart';
import '../view_model/coin_managment.dart';
import '../view_model/premium_provider_screen.dart';
import 'bottom_nav_bar_screen.dart';
import 'home_screen.dart';



class CoinPurchase extends StatefulWidget {
  final bool isFromSplash;
  final Function onDone;
  CoinPurchase({super.key, required this.isFromSplash, required this.onDone});

  @override
  State<CoinPurchase> createState() => _CoinPurchaseState();
}

class _CoinPurchaseState extends State<CoinPurchase> {
  int selected = 0;
  bool isPresed = false;
  bool isPresedButton = false;
  int SelectPremium = 0;
  double perweekprice = 0;
  int selectedContainer = 0;

  Offerings? _offerings;
  bool week = false;
  bool onemonth = true;
  bool threeweek = false;
  Map<String, Package>? availablePackages;
  Map<String, Package>? packageEntry;
  Package? selectedPackage;
  int index = 0;
  Package? firstCreditPackage;
  Package? secondCreditPackage;
  Package? thirdCreditPackage;

  bool _isCloseVisible = false;

  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges(shouldShow: false);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      fetchData();
      makeCloseVisible();

      showLog("AppLifecycleReactor premium Should Show false");
    });

    FirebaseAnalyticsService.logEvent(eventName: "CA_COIN_PURCHASE_SCREEN");
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
      final products = await Purchases.getProducts(["test"]);
      showLog("this is lis of product $products");
      offerings = await Purchases.getOfferings();
      firstCreditPackage = offerings.current!.availablePackages
          .where((test) =>
              test.storeProduct.identifier ==
              "charmai_coin_20")
          .first;
      secondCreditPackage = offerings.current!.availablePackages
          .where((test) =>
              test.storeProduct.identifier ==
              "charmai_coin_50")
          .first;

      selectedPackage = firstCreditPackage;

      availablePackages = {
        for (var package in offerings.current?.availablePackages ?? [])
          package.identifier: package
      };

      showLog("First Plan : ${firstCreditPackage}");
      showLog("Second Plan : ${secondCreditPackage}");

     // showLogJson(offerings.toJson());
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

  //For iOS
  // void showLogJson(Map<String, dynamic>? json, [int indentation = 0]) {
  //   json?.forEach((key, value) {
  //     showLog("this is json data");
  //     showLog('${' ' * indentation}$key: $value');
  //     if (value is Map<String, dynamic>) {
  //       showLogJson(value, indentation + 2);
  //     }
  //   });
  // }

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
      final purchaseResult = await Purchases.purchase(PurchaseParams.package(selectedPackage!));
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
          msg: "User cancelled",
          backgroundColor: Color(0xFF1C1D25),
        );
        if (kDebugMode) {
          showLog('User cancelled');
        }
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        Fluttertoast.showToast(
          msg: "You are not allowed to purchase",
          backgroundColor: Color(0xFF1C1D25),
        );
        showLog("You are not allowed to purchase");

        if (kDebugMode) {
          Fluttertoast.showToast(
            msg: "User not allowed to purchase",
            backgroundColor: Color(0xFF1C1D25),
          );
          showLog('User not allowed to purchase');
        }
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        Fluttertoast.showToast(
          msg: "Payment is Pending",
          backgroundColor: Color(0xFF1C1D25),
        );
        showLog("Payment is Pending");

        if (kDebugMode) {
          Fluttertoast.showToast(
            msg: "Payment is pending",
            backgroundColor: Color(0xFF1C1D25),
          );
          showLog('Payment is pending');
        }
      }
    }
  }

  double opacity = 1;

  //For iOS
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
        coinProvider.incrementCoins(AdsVariable.ca_first_plan_coin);
      } else {
        coinProvider.incrementCoins(AdsVariable.ca_second_plan_coin);
      }

      Fluttertoast.showToast(
        msg: "Your plan subscribe successfully",
        backgroundColor: Color(0xFF1C1D25),
      );
      showLog('Your plan subscribed successfully with bonus coins!');
      showLog('Your plan subscribe successfully');
      final prefs = await SharedPreferences.getInstance();
      bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      if (widget.isFromSplash == true && isFirstLaunch) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return BottomNavBarScreen();
          }),
        );
        //widget.onDone();
      } else {
        Navigator.pop(context);
        //widget.onDone();
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

  Widget getPremiumWidget() {
    var heightof = MediaQuery.of(context).size.height;
    var widthof = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //ai_appsforcoins
              buildContainer(
                  firstCreditPackage!,
                  0,
                  0),
              buildContainer(
                 secondCreditPackage!,
                  1,
                  1),
            ],
          ),
          SizedBox(
            height: 80.h,
          ),
          CustomeButtomWithImage(
            width: 950.w,
            height: 150.h,
            isShowAd: false, 
            image: "assets/intro/next_pressed.png",
            onTap: () {
              if (GlobalVariables.isPremiumUser) {
                _getPremiumVersion();
              } else {
                showToast("Please purchase week or year plan to get more coins",);
              }
            },
            child: Center(
              child:  CustomText(
                text: AppLocalizations.of(context)?.getmorecoins ??"Get more coins",
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
        body: Container(
          height: 1920.h,
          width: 1080.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 900.h,
                  width: 1080.w,
                  child: Stack(
                    children: [
                      Container(
                        height: 1000.h,
                        width: 1080.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/premium/image.webp"),
                            fit: BoxFit.fill
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 200.h,
                          width: 1080.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black
                                ]
                            )
                          ),
                        ),
                      ),
                      Container(
                        height: 1000.h,
                        width: 1080.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 100.h),
                            Row(
                              children: [
                                Spacer(),
                                Visibility(
                                  visible: _isCloseVisible,
                                  child: Opacity(
                                    opacity: 0.9,
                                    child: CustomeButtomWithImage(
                                      isShowAd: false,
                                      height: 80.h,
                                      width: 80.w,
                                      child: Container(),
                                      image: "assets/premium/cancle.png",
                                      onTap: () async {
                                        final prefs =
                                        await SharedPreferences.getInstance();
                                        prefs.setBool('isFirstLaunch', false);
                                        AppOpenAdManager appOpenAdManager =
                                        AppOpenAdManager();
                                        AppLifecycleReactor appLifecycleListener =
                                        AppLifecycleReactor(
                                          appOpenAdManager: appOpenAdManager,
                                        );
                                        appLifecycleListener.listenToAppStateChanges(
                                          shouldShow: true,
                                        );
                                        if (widget.isFromSplash) {
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
                                    ),
                                  ),
                                ),
                                SizedBox(width: 70.w),
                              ],
                            ),
                            Spacer(),
                            CustomText(
                              text: AppLocalizations.of(context)?.getmorecoins ??"Get More Coins",
                              fontSize: 70,
                              textColor: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              shadowsColor: Color(0xFFF090FF).withOpacity(0.6),
                              blurRadius: 20,
                              width: 600,
                              maxline: 1,
                              align: TextAlign.center,
                            ),
                            SizedBox(height: 20.h),
                            CustomText(
                              text: AppLocalizations.of(context)?.createrealistic ??"Create Realistic AI Face Swaps",
                              fontSize: 40,
                              fontFamily: 'regular',
                              textColor: Colors.white70,
                              width: 900,
                              align: TextAlign.center,
                              maxline: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 50.h,),
                Container(
                  height: 700.h,
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

                SizedBox(
                  height: 60.h,
                ),
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
                                      PrivacyPolicyPage('privacy')));
                        },
                        child: Text(
                          AppLocalizations.of(context)?.privacypolicy??
                              "Privacy Policy",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 34.sp),
                        ),
                      ),
                    ),
                    Container(
                      height: 60.h,
                      width: 5.w,
                      color: Colors.white,
                    ),
                    Container(
                      width: 340.w,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                           _opensubscriptions();
                        },
                        child: Text(
                          AppLocalizations.of(context)?.subscription ?? "Subscription",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 34.sp),
                        ),
                      ),
                    ),

                  ],
                )
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
  ) {
    if (packageEntry == null) {
      return Container();
    }
    int currentIndex = 0;
    List<MapEntry<String, Package>> entries =
        availablePackages?.entries.toList() ?? [];

    String price = packageEntry.storeProduct.priceString ?? "00.00";
    String firstCharacter = price.isNotEmpty ? price[0] : '';
    String perWeekPlan =
        ((packageEntry.storeProduct.price ?? 0) / 52).toStringAsFixed(2);
    String formattedPerWeekPlan = firstCharacter + " " + perWeekPlan;

    return GestureDetector(
      onTap: () {

          setState(() {
            index = setIndex;
            selectedPackage = packageEntry;
          });

      },
      child: Container(
        width: 350.w,
        height: 350.h,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(index == myIndex
                  ? "assets/premium/300coins.png"
                  : "assets/premium/img.png"),
              fit: BoxFit.fill),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30.h,),
            Image.asset("assets/premium/coin.png", height: 70.h,),
            SizedBox(height: 40.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  myIndex == 0
                      ? "${AdsVariable.ca_first_plan_coin} "
                      : "${AdsVariable.ca_second_plan_coin} ",
                  style: TextStyle(
                      fontSize: 45.sp,
                      fontFamily: "medium",
                      color: Color(0xFFFFFFFF)),
                ),
                SizedBox(height: 20.h,),
                Text(
                  AppLocalizations.of(context)?.credit ??"Credit",
                  style: TextStyle(
                      fontSize: 45.sp,
                      fontFamily: "bold",
                      color: Color(0xFFFFFFFF)),
                )
              ],
            ),
            Container(
              width: 200.w,
              height: 100.h,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Text(
                  packageEntry.storeProduct.priceString ?? "\$ 00",
                  style: TextStyle(
                      fontSize: 55.sp,
                      fontFamily: "bold",
                      color: index == myIndex
                          ? Color(0xFFFFFFFF)
                          : Color(0xFFA1A1A1)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

