import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final String? message;
  final SpinKitWaveType loadingType;

  const LoadingWidget({
    super.key,
    this.color,
    this.size = 50.0,
    this.message,
    this.loadingType = SpinKitWaveType.center,
  });

  @override
  Widget build(BuildContext context) {
    final widgetColor = color ?? Theme.of(context).primaryColor;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitWave(
            color: widgetColor,
            size: size,
            type: loadingType,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: widgetColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final Color? spinnerColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.spinnerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinKitDoubleBounce(
                    color: spinnerColor ?? Colors.white,
                    size: 50.0,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: TextStyle(
                        color: spinnerColor ?? Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}