import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/experience.dart';

class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final bool isSelected;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.experience,
    required this.isSelected,
    required this.onTap,
  });

  double _generateTilt(int id) {
    final int seed = id.hashCode;
    final math.Random random = math.Random(seed);
    // Random angle between -5 and +5 degrees
    final double tiltDegrees = (random.nextDouble() * 10) - 5;
    return tiltDegrees * math.pi / 180; 
  }

  @override
  Widget build(BuildContext context) {
    final double tiltAngle = _generateTilt(experience.id);

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: tiltAngle,
        child: Container(
          height: 150, 
          width: 100, 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.transparent : Colors.grey,
                    isSelected ? BlendMode.dst : BlendMode.saturation,
                  ),
                  child: experience.imageUrl.isNotEmpty
                      ? Image.network(
                          experience.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1A1A1A),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF6B7280),
                                size: 48,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: const Color(0xFF1A1A1A),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFF1A1A1A),
                          child: const Icon(
                            Icons.image,
                            color: Color(0xFF6B7280),
                            size: 48,
                          ),
                        ),
                ),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Selection Indicator
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
