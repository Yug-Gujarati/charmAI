import 'package:charmai/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final String? fontFamily;
  final double width;
  final int maxline;
  final TextAlign? align;
  final Color? shadowsColor;
  final int? blurRadius;
  final double? letterSpacing;
  final FontWeight? fontWeight;

  const CustomText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.textColor,
    this.fontFamily,
    required this.width,
    required this.maxline,
    this.align,
    this.shadowsColor,
    this.blurRadius,
    this.letterSpacing,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: maxline,
        textAlign: align,
        style: TextStyle(
          color: textColor,
          letterSpacing: letterSpacing,
          fontSize: fontSize.sp,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          shadows: shadowsColor != null
              ? [
                  Shadow(
                    color: shadowsColor!,
                    blurRadius: (blurRadius ?? 20).toDouble(),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}





class GradiantCustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final String? fontFamily;
  final double width;
  final int maxline;
  final TextAlign? align;
  final FontWeight? fontWeight;

  const GradiantCustomText({
    super.key,
    required this.text,
    required this.fontSize,
    this.fontFamily,
    required this.width,
    required this.maxline,
    this.align,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return AppColors.primaryActionGradient.createShader(bounds);
        },
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: maxline,
          textAlign: align,
          style: TextStyle(
            letterSpacing: 1.5,
            fontSize: fontSize.sp,
            fontFamily: fontFamily,
            fontWeight: fontWeight,

          ),
        ),
      ),
    );
  }
}
