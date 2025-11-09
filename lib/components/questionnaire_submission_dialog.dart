import 'package:eightclub_assignment/blocs/onboarding/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void handleNext(BuildContext context, OnboardingState state) {
    // Log the state
    print('=== Onboarding Question State ===');
    print('Question Text: ${state.questionText}');
    print('Audio Path: ${state.audioPath ?? "No audio"}');
    print('Video Path: ${state.videoPath ?? "No video"}');
    print('================================');

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Submission Complete',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Your onboarding questionnaire has been submitted successfully!',
          style: GoogleFonts.spaceGrotesk(color: const Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }