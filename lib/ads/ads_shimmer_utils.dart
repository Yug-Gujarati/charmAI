import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';



// Small Native Ad Shimmer (Compact)
class ShimmerSmallNative extends StatelessWidget {
  const ShimmerSmallNative({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: Duration(seconds: 2),
      interval: Duration(milliseconds: 500),
      color: Colors.white,
      colorOpacity: 0.4,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            color: Colors.white38, borderRadius: BorderRadius.circular(15)),
        width: Get.width,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: Get.width * 0.4,
                            height: 12.w,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: Get.width * 0.6,
                            height: 12.w,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: Get.width * 0.6,
                            height: 12.w,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10.w),
                  Container(
                    width: Get.width * 0.9,
                    height: 40.h,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(
                    height: 10.w,
                  )
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class ShimmerBigNative extends StatelessWidget {
  const ShimmerBigNative({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: Duration(seconds: 2),
      interval: Duration(milliseconds: 500),
      color: Colors.white,
      colorOpacity: 0.4,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
            color: Colors.white38, borderRadius: BorderRadius.circular(15)),
        width: Get.width,
        child: Column(
          children: [
            const Expanded(child: SizedBox()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Container(
                width: double.infinity,
                height: 105.h,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: Get.width * 0.4,
                            height: 12.w,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: Get.width * 0.6,
                            height: 12.w,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: Get.width * 0.6,
                            height: 12.w,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10.w),
                  Container(
                    width: Get.width * 0.9,
                    height: 40.h,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(
                    height: 10.w,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerFullNative extends StatelessWidget {
  const ShimmerFullNative({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: Duration(seconds: 2),
      interval: Duration(milliseconds: 500),
      color: Colors.white,
      colorOpacity: 0.4,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        height: 600,
        // Larger height for big native ad
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.circular(10),
        ),
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Vertically centered content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for Large Image
            Expanded(
              child: Container(
                width: double.infinity,
                height: 210.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(width: 50.w,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: Get.width * 0.4,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Ad Description
                    Container(
                      width: Get.width * 0.5,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: Get.width * 0.6,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Call to Action (CTA) button placeholder

                    Container(
                      width: Get.width * 0.6,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                )
              ],
            )
            // Ad Title
          ],
        ),
      ),
    );
  }
}
