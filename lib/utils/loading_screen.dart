// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
//
// @protected
// final scaffoldGlobalKey = GlobalKey<ScaffoldState>();
//
// class LoadingScreen {
//   final GlobalKey globalKey;
//
//   LoadingScreen(this.globalKey);
//
//   show([String? text]) {
//     showDialog<String>(
//       context: Get.context!,
//       builder: (BuildContext context) => Scaffold(
//         backgroundColor: const Color.fromRGBO(0, 0, 0, 0.3),
//         body: Container(
//           decoration: BoxDecoration(
//             // borderRadius: BorderRadius.circular(15.w),
//             color: Colors.black.withOpacity(0.5),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 ///CHANGE IT AS PER APP THEME
//                  CupertinoActivityIndicator(),
//                 SizedBox(
//                   height: 50.h,
//                 ),
//                 Text(
//                   "Scanning Ports",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 48.sp,
//                   ),
//                 ).marginSymmetric(horizontal: 50.w, vertical: 5.w),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   hide() {
//     if (Get.context == null) return;
//     Navigator.pop(Get.context!);
//   }
// }
//
// @protected
// var loadingScreen = LoadingScreen(scaffoldGlobalKey);
