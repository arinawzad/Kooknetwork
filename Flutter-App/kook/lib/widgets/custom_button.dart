import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.width,
    this.height = 50,
    this.borderRadius = 8,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SpinKitFadingCircle(
                color: Colors.white,
                size: 24,
              )
            : Text(
                text,
                style: textStyle ?? const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}