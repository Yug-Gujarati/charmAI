import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:charmai/utils/theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';
import 'custom_image_compare_slider.dart';
import 'custom_text.dart';

class CustomImageSelectionCard extends StatelessWidget {
  final File? originalImage;
  final String? networkImage;
  final dynamic generatedImage;
  final VoidCallback? onTap;
  final bool isLoading;

  const CustomImageSelectionCard({
    Key? key,
    this.originalImage,
    this.generatedImage,
    this.networkImage,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        dashPattern: [10, 5],
        strokeWidth: 2,
        padding: EdgeInsets.all(30.w),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4FC3F7),
              Color(0xFFF48FB1)
            ]),
        radius: Radius.circular(60.r),
      ),
      child: Container(
          height: 1000.h,
          width: 1080.w,
          decoration: BoxDecoration(
            color: AppColors.mainAppBackground,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: GestureDetector(
            onTap: isLoading ? null : onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                color: AppColors.mainAppBackground,
              ),
              child: _buildContent(context),
            ),
          ),
        ),
    );
  }

  Widget _buildContent(BuildContext context) {
    Widget content;

    // Show comparison slider if both images are available
    if (generatedImage != null && originalImage != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: CustomImageCompareSlider(
          originalImage: originalImage!,
          generatedImage: generatedImage!,
        ),
      );
    }
    // Show original image if only that is available
    else if (originalImage != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(50.r),
        child: Image.file(originalImage!, fit: BoxFit.cover),
      );
    }

    else if(networkImage != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CachedNetworkImage(
          imageUrl: networkImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    }
    // Show placeholder when no image is selected

    else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Image.asset("assets/change_hair_style/image_select.png", height: 100.h),
           SizedBox(height: 20.h),
          CustomText(
              text: AppLocalizations.of(context)?.taptoselectimage ??'Tap to select images',
              fontSize: 40,
              textColor: AppColors.primaryText,
              width: 500,
              fontFamily: 'medium',
              maxline: 1,
             align: TextAlign.center,
          ),

        ],
      );
    }

    // Loading overlay is now handled globally by LoadingScreen
    return content;
  }
}






