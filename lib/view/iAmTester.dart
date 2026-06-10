import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../ads/AdsVariable.dart';
import '../ads/analytics_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_constants.dart';
import '../utils/custom_appbar.dart';
import '../utils/custom_text.dart';
import '../utils/custome_buttom.dart';
import '../utils/navigation.dart';
import '../utils/theme.dart';


class Iamtestr extends StatefulWidget {
  final Function onDone;

  const Iamtestr({super.key, required this.onDone});

  @override
  State<Iamtestr> createState() => _IamtestrPageState();
}

Future<bool> checkInternetConnectivity(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    // No internet
    Fluttertoast.showToast(msg: "No internet connection!");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text("No internet connection!"),
    //     backgroundColor: Colors.red,
    //   ),
    // );
    return false;
  }

  return true;
}

class _IamtestrPageState extends State<Iamtestr> {
  late final WebViewController controller;

  TextEditingController textControllerUser = TextEditingController();
  TextEditingController textControllerPassword = TextEditingController();

  RxString userId = "".obs;
  RxString password = "".obs;

  @override
  void initState() {
    // TODO: implement initState
    FirebaseAnalyticsService.logEvent(eventName: "CA_IAMTESTER_SCREEN");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.black,

        body: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomAppbar(
                    onTap: (){
                      AppNavigation.NavigationBack(context);
                    },
                    name: AppLocalizations.of(context)?.iamtester ?? "I Am Tester",
                  showPremium: false,
                ),

                SizedBox(height: 20),
                // User ID TextField
                Center(
                  child: SizedBox(
                    width: Get.width * 0.9,
                    height: Get.height * 0.08,
                    child: TextField(
                      controller: textControllerUser,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        hintText: "Enter the user ID",
                        floatingLabelAlignment:
                            FloatingLabelAlignment.center,
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color(0xFFAC79FF)
                            )
                        ),
                      ),
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 1,
                      onChanged: (value) {
                        userId.value = value;
                      },
                    ),
                  ),
                ),

                SizedBox(height: 10.w), // Space between input fields
                // Password TextField
                SizedBox(
                  width: Get.width * 0.9,
                  height: Get.height * 0.08,
                  child: TextField(
                    controller: textControllerPassword,
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: "Enter the password",
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Color(0xFFAC79FF)
                          )
                      ),
                    ),
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    obscureText: true, // Hides password input
                    onChanged: (value) {
                      password.value = value;
                    },
                  ),
                ),

                CustomeButtomWithImage(
                  height: 130.h,
                  width: 600.w,
                  image: "assets/intro/next_pressed.png",
                  onTap: () async {
                    print(AdsVariable.ca_tester_email );
                    print(AdsVariable.ca_tester_password);
                    var result = await checkInternetConnectivity(context);
                    if (result) {
                      if (userId.value.isNotEmpty &&
                          password.value.isNotEmpty) {
                        if (userId.value == AdsVariable.ca_tester_email &&
                            password.value ==
                                AdsVariable.ca_tester_password) {
                          // next intent

                          showLog("api call");
                          widget.onDone();
                        } else {
                          String message =
                              userId.value != AdsVariable.ca_tester_email
                                  ? "Please Enter valid user id"
                                  : "Please Enter valid password";
                          Fluttertoast.showToast(
                            msg: message,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0,
                          );
                        }
                      } else {
                        String message =
                            userId.value.isEmpty
                                ? "Please Enter User id first"
                                : "Please Enter Password";
                        Fluttertoast.showToast(
                          msg: message,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(msg: "No Internet");
                    }
                  },
                  isShowAd: false,
                  child: Container(
                    child: Center(
                      child: CustomText(
                        text: AppLocalizations.of(context)?.continuee ??"Continue",
                        fontSize: 50,
                        fontFamily: 'obold',
                        textColor: AppColors.buttonText,
                        align: TextAlign.center,
                        width: 450,
                        maxline: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
