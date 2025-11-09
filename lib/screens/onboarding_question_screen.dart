import 'package:eight_club_assignment/screens/top_wavy_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/onboarding/onboarding_bloc.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/video_recorder_widget.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  State<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  final TextEditingController _textController = TextEditingController();
  final int _maxCharacters = 600;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleNext(OnboardingState state) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Submission Complete',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Your onboarding questionnaire has been submitted successfully!',
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFF9CA3AF),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: TopWavyProgressBar(
        progress: 1.0,
        onBack: () => Navigator.of(context).maybePop(),
        onClose: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
      body: Stack(
    children: [
      // Background image
      Positioned.fill(
        child: Image.asset(
          'assets/bg_8club.png',
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.4),
          colorBlendMode: BlendMode.srcOver,
        ),
      ),

      SafeArea(
  child: BlocBuilder<OnboardingBloc, OnboardingState>(
    builder: (context, state) {
      final showAudioButton = state.audioPath == null;
      final showVideoButton = state.videoPath == null;

      return LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final keyboardRatio =
              (keyboardHeight / (screenHeight > 0 ? screenHeight : 1))
                  .clamp(0.0, 1.0);

          // Base vertical position (0 = top, 1 = bottom). Tweak baseFraction to move content higher/lower by default.
          const double baseFraction = 0.9;
          // How much the content moves upward relative to keyboard height (0..1)
          const double adjustAmount = 0.6;

          final double adjustedFraction =
              (baseFraction - keyboardRatio * adjustAmount).clamp(0.45, 0.95);

          // Convert fraction (0..1) to Alignment.y (-1..1)
          final double alignY = (adjustedFraction * 2.0) - 1.0;

          return AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment(0, alignY),
            child: Padding(
              // ensure the column can scroll above the keyboard
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Prevent the content from exceeding the screen height
                  maxHeight: screenHeight * 0.95,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // important: shrink-wrap
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("02",
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white.withOpacity(0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          Text(
                            'Why do you want to host with us?',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        "Tell us about your intent and what motivates you to create experiences.",
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Text Answer
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _textController,
                              maxLength: _maxCharacters,
                              maxLines: 10,
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: '/Start typing here',
                                hintStyle: GoogleFonts.spaceGrotesk(
                                  color: Colors.white.withOpacity(0.16),
                                  fontSize: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                counterText: '',
                              ),
                              onChanged: (text) {
                                if (text.length <= _maxCharacters) {
                                  context
                                      .read<OnboardingBloc>()
                                      .add(UpdateQuestionText(text));
                                }
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 16, bottom: 12),
                              child: Text(
                                '${state.questionText.length}/$_maxCharacters',
                                style: GoogleFonts.spaceGrotesk(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Audio Recording Section
                      if (state.audioPath != null || state.isRecordingAudio) ...[
                        AudioRecorderWidget(),
                        const SizedBox(height: 16),
                      ],

                      // Video Recording Section
                      if (state.videoPath != null || state.isRecordingVideo) ...[
                        VideoRecorderWidget(),
                        const SizedBox(height: 16),
                      ],

                      // Bottom Actions (keeps inside same column; shrink-wrapped)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFF0A0A0A),
                              const Color(0xFF0A0A0A).withOpacity(0.95),
                              const Color(0xFF0A0A0A).withOpacity(0),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF1A1A1A).withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AudioRecordButton(),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  VideoRecordButton(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 0.8,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: state.questionText.isEmpty
                                      ? null
                                      : () => _handleNext(state),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Next',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: state.questionText.isEmpty
                                              ? Colors.white
                                                  .withOpacity(0.3)
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Image.asset(
                                        "assets/arrow-big-right-dash.png",
                                        height: 25,
                                        color: state.questionText.isEmpty
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ),
),

    ],
  ),
    );
  }
}

// Audio Record Button
class AudioRecordButton extends StatelessWidget {
  const AudioRecordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      buildWhen: (prev, curr) => prev.isRecordingAudio != curr.isRecordingAudio,
      builder: (context, state) {
        final isActive = state.isRecordingAudio;

        return GestureDetector(
          onTap: () {
            context.read<OnboardingBloc>().add(ToggleAudioRecording());
          },
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
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
                isActive ? Icons.mic : Icons.mic_none_outlined,
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



// Video Record Button
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
