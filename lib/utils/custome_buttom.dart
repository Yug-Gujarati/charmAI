import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomeButtomWithImage extends StatefulWidget {
  final double height;
  final double width;
  final Widget child;
  final String image;
  final Function onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isShowAd;
  const CustomeButtomWithImage({super.key, required this.height, required this.width, required this.child, required this.image, required this.onTap, this.margin, this.padding, required this.isShowAd});

  @override
  State<CustomeButtomWithImage> createState() => _CustomeButtomWithImageState();
}

class _CustomeButtomWithImageState extends State<CustomeButtomWithImage> {

  bool isPress = false;

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
        if(widget.isShowAd){
            widget.onTap();
        }
        else{
          widget.onTap();
        }
      },
      child: Opacity(
        opacity: isPress ? 0.5 : 1,
        child: Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(widget.image),
              )),
          child: widget.child,
        ),
      ),
    );
  }
}


class CustomeButtomWithImageFit extends StatefulWidget {
  final double height;
  final double width;
  final Widget child;
  final String image;
  final Function onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isShowAd;
  const CustomeButtomWithImageFit({super.key, required this.height, required this.width, required this.child, required this.image, required this.onTap, this.margin, this.padding, required this.isShowAd});

  @override
  State<CustomeButtomWithImageFit> createState() => _CustomeButtomWithImageFitState();
}

class _CustomeButtomWithImageFitState extends State<CustomeButtomWithImageFit> {

  bool isPress = false;

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
        if(widget.isShowAd){
          // AdsSplashUtils.onShowAds(context, () {
          widget.onTap();
          //});
        }
        else{
          widget.onTap();
        }
      },
      child: Opacity(
        opacity: isPress ? 0.5 : 1,
        child: Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(widget.image),
                fit: BoxFit.fill
              )),
          child: widget.child,
        ),
      ),
    );
  }
}



class CustomeButtom extends StatefulWidget {
  final double height;
  final double width;
  final Widget child;
  final Function onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isShowAd;
  final Color color;
  const CustomeButtom({super.key, required this.height, required this.width, required this.child, required this.onTap, this.margin, this.padding, required this.isShowAd, required this.color});

  @override
  State<CustomeButtom> createState() => _CustomeButtomState();
}

class _CustomeButtomState extends State<CustomeButtom> {

  bool isPress = false;

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
        if(widget.isShowAd){
          // AdsSplashUtils.onShowAds(context, () {
          widget.onTap();
          //});
        }
        else{
          widget.onTap();
        }
      },
      child: Opacity(
        opacity: isPress ? 0.5 : 1,
        child: Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color,
              borderRadius: BorderRadius.circular(10),

              ),
          child: widget.child,
        ),
      ),
    );
  }
}



class CustomeButtomTrasperant extends StatefulWidget {
  final double height;
  final double width;
  final Widget child;
  final Function onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  const CustomeButtomTrasperant({super.key, required this.height, required this.width, required this.child, required this.onTap, this.margin, this.padding});

  @override
  State<CustomeButtomTrasperant> createState() => _CustomeButtomTrasperantState();
}

class _CustomeButtomTrasperantState extends State<CustomeButtomTrasperant> {

  bool isPress = false;

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
      child: AnimatedContainer(
        height: widget.height,
        width: widget.width,
        margin: widget.margin,
        padding: widget.padding,
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPress
                ? [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ]
                : [
              Colors.white.withOpacity(0.1),
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
        child: widget.child,
      ),
    );
  }
}
