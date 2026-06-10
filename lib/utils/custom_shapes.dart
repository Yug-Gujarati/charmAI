import 'package:flutter/material.dart';

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0.5 * size.width, size.height * 0.35);
    path.cubicTo(
      0.2 * size.width,
      size.height * 0.1,
      -0.25 * size.width,
      size.height * 0.6,
      0.5 * size.width,
      size.height,
    );
    path.moveTo(0.5 * size.width, size.height * 0.35);
    path.cubicTo(
      0.8 * size.width,
      size.height * 0.1,
      1.25 * size.width,
      size.height * 0.6,
      0.5 * size.width,
      size.height,
    );
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.618, h * 0.35);
    path.lineTo(w, h * 0.35);
    path.lineTo(w * 0.691, h * 0.57);
    path.lineTo(w * 0.809, h);
    path.lineTo(w * 0.5, h * 0.75);
    path.lineTo(w * 0.191, h);
    path.lineTo(w * 0.309, h * 0.57);
    path.lineTo(0, h * 0.35);
    path.lineTo(w * 0.382, h * 0.35);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.25, 0);
    path.lineTo(size.width * 0.75, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.75, size.height);
    path.lineTo(size.width * 0.25, size.height);
    path.lineTo(0, size.height * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var width = size.width;
    var height = size.height;

    path.moveTo(width * 0.2, height * 0.7);
    path.quadraticBezierTo(0, height * 0.7, 0, height * 0.5);
    path.quadraticBezierTo(0, height * 0.2, width * 0.2, height * 0.2);
    path.quadraticBezierTo(width * 0.3, 0, width * 0.5, 0);
    path.quadraticBezierTo(width * 0.7, 0, width * 0.8, height * 0.2);
    path.quadraticBezierTo(width, height * 0.2, width, height * 0.5);
    path.quadraticBezierTo(width, height * 0.7, width * 0.8, height * 0.7);
    path.lineTo(width * 0.2, height * 0.7);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MessageBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.85),
        Radius.circular(16),
      ),
    );
    path.moveTo(size.width * 0.2, size.height * 0.85);
    path.lineTo(size.width * 0.1, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.85);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
