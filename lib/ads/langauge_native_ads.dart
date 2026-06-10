// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// import '../utils/app_constants.dart';
// import 'ads_shimmer_utils.dart';
//
// class LanguageNativeAds {
//   //LANGUAGE FIRST NATIVE AD
//   static NativeAd? nativeLanguageAd;
//   static RxBool isNativeAdLanguageLoaded = false.obs;
//   static RxBool isNativeAdLanguageFailed = false.obs;
//
//   Future<NativeAd> loadFirstNative(String adUnitId, bool isSmallNative) async {
//     showLog("isSmallNative--->$isSmallNative");
//     print("LOAD FIRST NATIVE");
//     isNativeAdLanguageLoaded.value = false;
//     nativeLanguageAd = NativeAd(
//       adUnitId: adUnitId.toString(),
//       factoryId: isSmallNative ? 'small' : 'big',
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           nativeLanguageAd = ad as NativeAd?;
//           isNativeAdLanguageLoaded.value = true;
//           showLog('isLoaded loadNative');
//         },
//         onAdFailedToLoad: (ad, error) {
//           showLog('onAdFailedToLoad loadNative');
//           nativeLanguageAd!.dispose();
//           isNativeAdLanguageLoaded.value = false;
//           isNativeAdLanguageFailed.value = true;
//         },
//       ),
//       request: const AdRequest(),
//     );
//     try {
//       await nativeLanguageAd!.load();
//     } catch (e) {
//       showLog("ERROR--->${e.toString()}");
//       nativeLanguageAd!.dispose();
//       nativeLanguageAd = null;
//       isNativeAdLanguageLoaded.value = false;
//       isNativeAdLanguageFailed.value = true;
//     }
//     return nativeLanguageAd!;
//   }
//
//   //LANGUAGE SECOND NATIVE AD
//   static NativeAd? nativeSecondLanguageAd;
//   static RxBool isNativeAdSecondLanguageLoaded = false.obs;
//   static RxBool isNativeAdSecondLanguageFailed = false.obs;
//
//   Future<NativeAd> loadSecondNative(String adUnitId, bool isSmallNative) async {
//     showLog("isSmallNative--->$isSmallNative");
//     showLog("LOAD SECOND NATIVE");
//     isNativeAdSecondLanguageLoaded.value = false;
//     nativeSecondLanguageAd = NativeAd(
//       adUnitId: adUnitId.toString(),
//       factoryId: isSmallNative ? 'small' : 'big',
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           nativeSecondLanguageAd = ad as NativeAd?;
//           isNativeAdSecondLanguageLoaded.value = true;
//           showLog('isLoaded loadNative');
//         },
//         onAdFailedToLoad: (ad, error) {
//           showLog('onAdFailedToLoad loadNative');
//           nativeSecondLanguageAd!.dispose();
//           isNativeAdSecondLanguageLoaded.value = false;
//           isNativeAdSecondLanguageFailed.value = true;
//         },
//       ),
//       request: const AdRequest(),
//     );
//     try {
//       await nativeSecondLanguageAd!.load();
//     } catch (e) {
//       showLog("ERROR--->${e.toString()}");
//       nativeSecondLanguageAd!.dispose();
//       nativeSecondLanguageAd = null;
//       isNativeAdSecondLanguageLoaded.value = false;
//       isNativeAdSecondLanguageFailed.value = true;
//     }
//     return nativeSecondLanguageAd!;
//   }
// }
//
// /// Native ads
// class FirstLangaugeNativeAdsWidget extends StatefulWidget {
//   final bool isSmallNative;
//   final NativeAd? showNativeAd;
//   final double? height;
//
//   const FirstLangaugeNativeAdsWidget(
//       {super.key, required this.showNativeAd, required this.isSmallNative, this.height});
//
//   @override
//   State<FirstLangaugeNativeAdsWidget> createState() => _FirstLangaugeNativeAdsWidgetState();
// }
//
// /// Native ads
// class _FirstLangaugeNativeAdsWidgetState extends State<FirstLangaugeNativeAdsWidget> {
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((callback) {
//       setState(() {});
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     showLog("CHECK NULL >> ${LanguageNativeAds.isNativeAdLanguageLoaded.value}");
//     return Obx(() => LanguageNativeAds.isNativeAdLanguageLoaded.value && widget.showNativeAd != null
//         ? StatefulBuilder(builder: (context, setState) {
//             return Container(
//               margin: EdgeInsets.only(top: 20.h),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5.w),
//                 color: Colors.transparent,
//               ),
//               padding: EdgeInsets.only(bottom: 10.w, top: 0.w),
//               width: 1080.w,
//               height: 300,
//               child: AdWidget(ad: widget.showNativeAd!),
//             );
//           })
//         : getShimmerWidget());
//   }
//
//   Widget getShimmerWidget() {
//     if (LanguageNativeAds.isNativeAdLanguageFailed.value) {
//       return Container(
//         height: 0,
//       );
//     } else {
//       print("this is ismall1 ${widget.isSmallNative}");
//       return widget.isSmallNative ? const ShimmerSmallNative() : const ShimmerBigNative();
//     }
//   }
// }
//
// /// Native ads
// class SecondLanguageNativeAdsWidget extends StatefulWidget {
//   final bool isSmallNative;
//   final NativeAd? showNativeAd;
//   final double? height;
//
//   const SecondLanguageNativeAdsWidget(
//       {super.key, required this.showNativeAd, required this.isSmallNative, this.height});
//
//   @override
//   State<SecondLanguageNativeAdsWidget> createState() => _SecondLanguageNativeAdsWidgetState();
// }
//
// /// Native ads
// class _SecondLanguageNativeAdsWidgetState extends State<SecondLanguageNativeAdsWidget> {
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((callback) {
//       setState(() {});
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     showLog("CHECK NULL >> ${LanguageNativeAds.isNativeAdSecondLanguageLoaded.value}");
//     return Obx(
//         () => LanguageNativeAds.isNativeAdSecondLanguageLoaded.value && widget.showNativeAd != null
//             ? StatefulBuilder(builder: (context, setState) {
//                 return Container(
//                   margin: EdgeInsets.only(top: 20.h),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5.w),
//                     color: Colors.transparent,
//                   ),
//                   padding: EdgeInsets.only(bottom: 10.w, top: 0.w),
//                   width: 1080.w,
//                   height: 300,
//                   child: AdWidget(ad: widget.showNativeAd!),
//                 );
//               })
//             : getShimmerWidget());
//   }
//
//   Widget getShimmerWidget() {
//     if (LanguageNativeAds.isNativeAdSecondLanguageFailed.value) {
//       return Container(
//         height: 0,
//       );
//     } else {
//       print("this is ismall ${widget.isSmallNative}");
//       return widget.isSmallNative ? const ShimmerSmallNative() : const ShimmerBigNative();
//     }
//   }
// }
