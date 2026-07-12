import 'package:charmai/utils/theme.dart';
import 'package:charmai/view/home_screen.dart';
import 'package:charmai/view/options_screen.dart';
import 'package:charmai/view/premium_screen.dart';
import 'package:charmai/view/saved_images_grid_screen.dart';
import 'package:charmai/view/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../ads/analytics_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/globalVariables.dart';
import '../utils/navigation.dart';
import '../view_model/coin_managment.dart';
import 'coin_purchase_screen.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OptionsScreen(),
    const HomeScreen(),
    const SavedImages(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _fetchCoins();
    FirebaseAnalyticsService.logEvent(eventName: "CA_BOTTOM_NAV_BAR_SCREEN");

    super.initState();
  }


  int currentCoins = 0;

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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 50.w,
              right: 50.w,
              top: 100.h,
              bottom: 10.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomeButtomWithImage(
                  height: 100.h,
                  width: 60.w,
                  child: Container(),
                  image: "assets/home/categorys_unpress.png",
                  onTap: () {
                    AppNavigation.NavigationPush(context, SettingPage());
                  },
                  isShowAd: false,
                ),
                Spacer(),
                CustomText(
                  text: AppLocalizations.of(context)?.charmAI ??'Charm AI',
                  fontSize: 70,
                  textColor: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  shadowsColor: const Color(0xFF4FC3F7).withOpacity(0.6),
                  blurRadius: 20,
                  width: 450,
                  maxline: 1,
                  align: TextAlign.center,
                ),
                SizedBox(width: 30.w),
                CustomeButtomWithImageFit(
                  height: 80.h,
                  width: 220.w,
                  isShowAd: false,
                  image: "assets/home/premium.png",
                  onTap: () {
                    if (GlobalVariables.isPremiumUser) {
                      AppNavigation.NavigationPush(context, CoinPurchase(
                        isFromSplash: false,
                        onDone: () {},
                      ),);
                    } else {
                      AppNavigation.NavigationPush(context, PremiumScreen(
                        isFromSplash: false,
                        from: "home",
                        onDone: () {},
                      ),);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 60.w,
                      top: 0.h,
                      bottom: 0.h,
                      right: 1.w,
                    ),
                    alignment: Alignment.center,
                    child: Consumer<CoinProvider>(
                      builder: (context, value, child) {
                        return Text(
                          '${value.coins}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'medium',
                            fontSize: 45.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
                Positioned(
                  bottom: 10.h,
                  left: 20.w,
                  right: 20.w,
                  child: Container(
                    height: 130.h,
                    width: 700.w,
                    margin: EdgeInsets.fromLTRB(120.w, 0.w, 120.w, 70.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withOpacity(0.9),

                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),

                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, "assets/home/categorys.png", 'assets/home/categorys_unpress.png', 'Category'),
                          _buildNavItem(1, "assets/home/options.png", 'assets/home/options_unpress.png', 'Options'),
                          _buildNavItem(2, "assets/home/saved_pressed.png", 'assets/home/saved_unpressedd.png' ,'Saved'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildNavItem(int index, String imagePath, String unselectedImage, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSelected
              ? Image.asset(imagePath, height: 25)
              : Image.asset(unselectedImage, height: 25)
        ],
      ),
    );
  }
}
