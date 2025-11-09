import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class TopWavyProgressBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress; // 0.0–1.0
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  const TopWavyProgressBar({
    super.key,
    required this.progress,
    this.onBack,
    this.onClose,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: preferredSize.height + topPadding,
      width: double.infinity,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 80,
            sigmaY: 80,
          ), 
          child: Container(
            color: Colors.white.withOpacity(0.1), 
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  //  Back Button 
                  IconButton(
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              
                  //  Wavy Progress Bar (fills remaining space) 
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        height: 18,
                        child: CustomPaint(
                          painter: _StaticWavyProgressPainter(progress: progress),
                        ),
                      ),
                    ),
                  ),
              
                  //  Close Button
                  IconButton(
                    onPressed:
                        onClose ??
                        () => Navigator.of(context).popUntil((r) => r.isFirst),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticWavyProgressPainter extends CustomPainter {
  final double progress;

  _StaticWavyProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final inactivePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8A63D2),
          Color(0xFFB388EB),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Path inactivePath = Path();
    final Path activePath = Path();

    // Wave properties
    const double amplitude = 4.0;
    const double wavelength = 40.0;
    final double centerY = size.height / 2;

    // Inactive full line
    for (double x = 0; x <= size.width; x++) {
      final double y =
          centerY + math.sin(x / wavelength * 2 * math.pi) * amplitude;
      if (x == 0) {
        inactivePath.moveTo(x, y);
      } else {
        inactivePath.lineTo(x, y);
      }
    }

    // Active portion (progress)
    for (double x = 0; x <= size.width * progress; x++) {
      final double y =
          centerY + math.sin(x / wavelength * 2 * math.pi) * amplitude;
      if (x == 0) {
        activePath.moveTo(x, y);
      } else {
        activePath.lineTo(x, y);
      }
    }

    canvas.drawPath(inactivePath, inactivePaint);
    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(covariant _StaticWavyProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
