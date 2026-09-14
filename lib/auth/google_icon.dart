import 'package:flutter/material.dart';

/// Simple Google "G" placeholder icon.
/// For a pixel-perfect multi-color G, use the `flutter_svg` package
/// with an official Google logo SVG asset instead.
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.g_mobiledata,
      size: 22,
      color: Color(0xFF4285F4),
    );
  }
}

