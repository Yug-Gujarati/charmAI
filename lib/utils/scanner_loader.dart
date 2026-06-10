import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io';

class ScannerLoader extends StatefulWidget {
  final dynamic imagePath; 
  final double? height;
  final double? width;
  final Widget? child; 
  final BorderRadiusGeometry? borderRadius;

  const ScannerLoader({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.child,
    this.borderRadius,
  });

  @override
  State<ScannerLoader> createState() => _ScannerLoaderState();
}

class _ScannerLoaderState extends State<ScannerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildImage() {
    if (widget.imagePath is File) {
      return Image.file(widget.imagePath as File, fit: BoxFit.cover);
    } else if (widget.imagePath is String) {
      String path = widget.imagePath as String;
      if (path.startsWith('http')) {
        return Image.network(path, fit: BoxFit.cover);
      } else {
        return Image.asset(path, fit: BoxFit.cover);
      }
    }
    return Container(color: Colors.grey[900]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(24),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Background Image
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
              child: _buildImage(),
            ),
          ),
          
          // Scanning Line
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // The scanning horizontal line
                      Positioned(
                        top: _animation.value * constraints.maxHeight,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightBlueAccent.withOpacity(0.0),
                                Colors.lightBlueAccent,
                                Colors.pinkAccent,
                                Colors.pinkAccent.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          
          // Foreground additional widgets (like progress text, badges)
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
