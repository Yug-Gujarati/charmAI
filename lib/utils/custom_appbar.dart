import 'dart:ui';

import 'package:charmai/utils/report_bottom_sheet.dart';
import 'package:charmai/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../view/coin_purchase_screen.dart';
import '../view/premium_screen.dart';
import '../view_model/coin_managment.dart';
import 'custom_text.dart';
import 'custome_buttom.dart';
import 'globalVariables.dart';

class CustomAppbar extends StatelessWidget {
  final Function onTap;
  final String name;
  final bool showPremium;
  final bool showReport;
  const CustomAppbar({super.key, required this.onTap, required this.name, required this.showPremium, this.showReport=false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30.r),
        bottomRight: Radius.circular(30.r),
      ),
      child: SizedBox(
        width: 1080.w,
        height: 200.h,
        child: Container(
          padding: EdgeInsets.only(top: 100.h),
          width: double.infinity,
          child: Row(
            children: [
              CustomeButtomWithImage(
                  height: 100.h,
                  width: 100.w,
                  isShowAd: false,
                  image: "assets/language/back.png",
                  onTap: () {
                    onTap();
                  },
                  child: Container()),
              Spacer(),
              SizedBox(width: 80.w),
              CustomText(
                  text: name,
                  fontSize: 50,
                  textColor: AppColors.primaryText,
                  fontFamily: "bold",
                  width: 500,
                  align: TextAlign.center,
                  maxline: 1),
              Spacer(),

              showPremium
              ? CustomeButtomWithImageFit(
                height: 80.h,
                width: 220.w,
                isShowAd: false,
                image: "assets/home/premium.png",
                onTap: () {
                  if (GlobalVariables.isPremiumUser) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoinPurchase(
                          isFromSplash: false,
                          onDone: () {},
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PremiumScreen(
                          isFromSplash: false,
                          from: "home",
                          onDone: () {},
                        ),
                      ),
                    );
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
              )
              : SizedBox(width: 20.w),

              showReport
              ? CustomeButtom(
                height: 80.h,
                width: 220.w,
                isShowAd: false,
                color: Colors.transparent,

                onTap: (){
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // needed so it isn't clipped/pushed oddly by the keyboard
                    builder: (_) => ReportBottomSheet(),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: 60.w,
                    top: 0.h,
                    bottom: 0.h,
                    right: 1.w,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.report, color: AppColors.primaryText,),
                ),
              )
              : SizedBox(width: 20.w),

            ],
          ),
        ),
      ),
    );
  }
}

Widget vSpace(double height) => SizedBox(height: height);

Widget hSpace(double width) => SizedBox(width: width);