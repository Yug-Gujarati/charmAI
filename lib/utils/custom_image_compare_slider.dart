import 'dart:io';
import 'package:flutter/material.dart';

class CustomImageCompareSlider extends StatefulWidget {
  final dynamic originalImage; // Can be File or String (Asset path)
  final dynamic generatedImage; // Can be File, String (URL/Asset path)

  const CustomImageCompareSlider({
    Key? key,
    required this.originalImage,
    required this.generatedImage,
  }) : super(key: key);

  @override
  State<CustomImageCompareSlider> createState() =>
      _CustomImageCompareSliderState();
}

class _CustomImageCompareSliderState extends State<CustomImageCompareSlider> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sliderValue =
                  (_sliderValue + details.delta.dx / constraints.maxWidth)
                      .clamp(0.0, 1.0);
            });
          },
          child: Stack(
            children: [
              // Generated Image (Background)
              Positioned.fill(child: _buildImage(widget.generatedImage)),

              // Original Image (Foreground, clipped)
              Positioned.fill(
                child: ClipRect(
                  clipper: _SliderClipper(_sliderValue),
                  child: _buildImage(widget.originalImage),
                ),
              ),

              // Slider Handle
              Positioned(
                left:
                    constraints.maxWidth * _sliderValue -
                    1.5, // Center the line
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: Colors.white),
              ),
              Positioned(
                left:
                    constraints.maxWidth * _sliderValue -
                    15, // Center the handle
                top: constraints.maxHeight * 0.5 - 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.compare_arrows,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(dynamic image) {
    if (image is File) {
      return Image.file(image, fit: BoxFit.cover);
    } else if (image is String) {
      if (image.startsWith('http') || image.startsWith('https')) {
        return Image.network(
          image,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.error));
          },
        );
      } else {
        // Assume asset path
        return Image.asset(image, fit: BoxFit.cover);
      }
    } else {
      return const SizedBox();
    }
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double value;

  _SliderClipper(this.value);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
