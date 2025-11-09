import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16), required int blur, required double borderWidth, required LinearGradient borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          // Subtle background blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(),
          ),
          // Border gradient
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF101010),
                  Color(0xFFFFFFFF),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          // Inner radial gradient fill
          Padding(
            padding: const EdgeInsets.all(0.5),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const RadialGradient(
                  center: Alignment.center,
                  radius: 2,
                  colors: [
                    Color(0xFF444444),
                    Color(0xFF222222),
                    Color(0xFF444444),
                  ],
                  stops: [0.5, 1, 2],
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
