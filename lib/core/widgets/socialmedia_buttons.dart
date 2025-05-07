import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButton extends StatelessWidget {
  /// Path to your asset image (e.g. 'assets/icons/facebook.png')
  final String assetPath;

  /// Called when the user taps the button
  final VoidCallback? onPressed;

  /// Background color (default light grey)
  final Color backgroundColor;

  const CustomIconButton({
    super.key,
    required this.assetPath,
    this.onPressed,
    this.backgroundColor = const Color(0xFFF1F4F8),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 103,
        height: 55,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: assetPath.toLowerCase().endsWith('.svg')
            ? SvgPicture.asset(
                assetPath,
                width: 30,
                height: 30,
                // fit: BoxFit.contain,
              )
            : Image.asset(
                assetPath,
                width: 30,
                height: 30,
              ),
      ),
    );
  }
}
