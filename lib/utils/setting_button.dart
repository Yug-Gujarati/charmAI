import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingButton extends StatefulWidget {
  final double height;
  final double width;
  final String text;
  final String image;
  final Function onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  const SettingButton(
      {super.key,
      required this.height,
      required this.width,
      required this.text,
      required this.image,
      required this.onTap,
      this.margin,
      this.padding});

  @override
  State<SettingButton> createState() => _SettingButtonState();
}

class _SettingButtonState extends State<SettingButton> {
  bool isPress = false;
  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () {
        setState(() {
          isPress = false;
        });
      },
      onTapDown: (d) {
        setState(() {
          isPress = true;
        });
      },
      onTapUp: (ui) {
        setState(() {
          isPress = false;
        });
      },
      onTap: () {
        widget.onTap();
      },
      child: Opacity(
        opacity: isPress ? 0.5 : 1,
        child: Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:  [
              Colors.white.withOpacity(0.05),

                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isPress
                  ? Colors.white.withOpacity(0.09)
                  : Colors.white.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30.w,
              ),
              Image.asset(widget.image, height: 50.h,),

              SizedBox(
                width: 50.w,
              ),
              SizedBox(
                width: 550.w,
                child: Text(
                  widget.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'bold',
                      fontSize: 50.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
