import 'package:eightclub_assignment/blocs/onboarding/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoRecordButton extends StatelessWidget {
  const VideoRecordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      buildWhen: (prev, curr) => prev.isRecordingVideo != curr.isRecordingVideo,
      builder: (context, state) {
        final isActive = state.isRecordingVideo;

        return GestureDetector(
          onTap: () {
            context.read<OnboardingBloc>().add(ToggleVideoRecording());
          },
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                gradient: isActive
                    ? RadialGradient(
                        colors: [
                          const Color(0xFF222222).withOpacity(0.95),
                          const Color(0xFF888888).withOpacity(0.3),
                          const Color(0xFF888888).withOpacity(0.5),
                        ],
                        center: Alignment.topLeft,
                        radius: 0.9,
                      )
                    : null,
              ),
              child: Icon(
                isActive ? Icons.videocam : Icons.videocam_outlined,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}