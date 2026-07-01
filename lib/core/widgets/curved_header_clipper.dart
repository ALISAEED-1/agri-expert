import 'package:flutter/material.dart';

/// Clips the bottom edge of the header image into a smooth downward curve.
class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 20)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + 5,
        size.width,
        size.height - 20,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
