import 'package:eightclub_assignment/screens/top_wavy_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/experience/experience_bloc.dart';
import '../widgets/experience_card.dart';
import 'onboarding_question_screen.dart';

class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen> {
  final TextEditingController _textController = TextEditingController();
  final int _maxCharacters = 250;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleNext(ExperienceLoaded state) {
    // Log the state
    print('=== Experience Selection State ===');
    print('Selected Experience IDs: ${state.selectedExperienceIds.toList()}');
    print('Experience Text: ${state.experienceText}');
    print('================================');

    // Navigate to question screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingQuestionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopWavyProgressBar(
        progress: 0.5,
        onBack: () => Navigator.of(context).maybePop(),
        onClose: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // --- Background Image ---
          Positioned.fill(
            child: Image.asset(
              'assets/bg_8club.png', 
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4), 
              colorBlendMode: BlendMode.srcOver,
            ),
          ),

          SafeArea(
            child: BlocBuilder<ExperienceBloc, ExperienceState>(
              builder: (context, state) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;
                    final keyboardHeight = MediaQuery.of(
                      context,
                    ).viewInsets.bottom;
                    final keyboardRatio =
                        (keyboardHeight / (screenHeight > 0 ? screenHeight : 1))
                            .clamp(0.0, 1.0);

                    const double baseFraction = 0.9; // near bottom
                    const double adjustAmount =
                        0.6; // how much it moves up with keyboard
                    final double adjustedFraction =
                        (baseFraction - keyboardRatio * adjustAmount).clamp(
                          0.45,
                          0.95,
                        );
                    final double alignY = (adjustedFraction * 2.0) - 1.0;

                    //  Handle loading & error outside the animated container 
                    if (state is ExperienceLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (state is ExperienceError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load experiences',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ExperienceBloc>().add(
                                  LoadExperiences(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is! ExperienceLoaded) {
                      return const SizedBox.shrink();
                    }

                    return AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(0, alignY),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: keyboardHeight),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.95,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("01",
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        'What kind of hotspots do you want to host?',
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  )
                                ),

                                // Experience Cards
                                SizedBox(
                                  height: 130,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.experiences.length,
                                    itemBuilder: (context, index) {
                                      final experience =
                                          state.experiences[index];
                                      final isSelected = state
                                          .selectedExperienceIds
                                          .contains(experience.id);
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16.0,
                                        ),
                                        child: SizedBox(
                                          width: 130,
                                          height: 80,
                                          child: ExperienceCard(
                                            experience: experience,
                                            isSelected: isSelected,
                                            onTap: () {
                                              context
                                                  .read<ExperienceBloc>()
                                                  .add(
                                                    ToggleExperienceSelection(
                                                      experience.id,
                                                    ),
                                                  );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Description Input
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
                                        maxLines: 3,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              '/Describe your perfect hotspot',
                                          hintStyle: GoogleFonts.spaceGrotesk(
                                            color: Colors.white.withOpacity(
                                              0.16,
                                            ),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                          counterText: '',
                                        ),
                                        onChanged: (text) {
                                          if (text.length <= _maxCharacters) {
                                            context.read<ExperienceBloc>().add(
                                              UpdateExperienceText(text),
                                            );
                                          }
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                          bottom: 12,
                                        ),
                                        child: Text(
                                          '${state.experienceText.length}/$_maxCharacters',
                                          style: GoogleFonts.spaceGrotesk(
                                            color: const Color(0xFF6B7280),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Next Button
                                Container(
                                  padding: const EdgeInsets.all(0),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xFF0A0A0A),
                                        Color(0xF20A0A0A),
                                        Color(0x000A0A0A),
                                      ],
                                    ),
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: state.experienceText.isNotEmpty
                                          ? const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Color(0xFF101010),
                                                Color(0xFFFFFFFF),
                                              ],
                                            )
                                          : null, // No gradient border if text is empty
                                      border: state.experienceText.isEmpty
                                          ? Border.all(
                                              color: Colors.white.withOpacity(
                                                0.1,
                                              ),
                                              width: 0.5,
                                            )
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          gradient:
                                              state.experienceText.isNotEmpty
                                              ? const RadialGradient(
                                                  center: Alignment.center,
                                                  radius: 5,
                                                  colors: [
                                                    Color(0xFF222222),
                                                    Color(0xFF444444),
                                                    Color(0xFF222222),
                                                  ],
                                                  stops: [0, 0.5, 0.8],
                                                )
                                              : null,
                                          color: state.experienceText.isEmpty
                                              ? const Color(0xFF1A1A1A)
                                              : null,
                                          boxShadow:
                                              state.experienceText.isNotEmpty
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed:
                                                state.experienceText.isEmpty
                                                ? null
                                                : () => _handleNext(state),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Next',
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            state
                                                                .experienceText
                                                                .isNotEmpty
                                                            ? Colors.white
                                                            : Colors.white
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                      ),
                                                ),
                                                const SizedBox(width: 6),
                                                Image.asset(
                                                  "assets/arrow-big-right-dash.png",
                                                  height: 25,
                                                  color:
                                                      state
                                                          .experienceText
                                                          .isNotEmpty
                                                      ? Colors.white
                                                      : Colors.white
                                                            .withOpacity(0.3),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
