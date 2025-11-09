// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:record/record.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../blocs/onboarding/onboarding_bloc.dart';

// class AudioRecorderWidget extends StatefulWidget {
//   const AudioRecorderWidget({super.key});

//   @override
//   State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
// }

// class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
//     with SingleTickerProviderStateMixin {
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   Timer? _timer;
//   int _recordDuration = 0;
//   List<double> _waveformData = [];
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _audioRecorder.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _startRecording() async {
//     try {
//       // Request permission
//       if (await Permission.microphone.request().isGranted) {
//         final directory = await getApplicationDocumentsDirectory();
//         final path =
//             '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

//         await _audioRecorder.start(
//           const RecordConfig(
//             encoder: AudioEncoder.aacLc,
//             bitRate: 128000,
//             sampleRate: 44100,
//           ),
//           path: path,
//         );

//         setState(() {
//           _recordDuration = 0;
//           _waveformData = [];
//         });

//         _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//           setState(() {
//             _recordDuration += 100;
//             // Simulate waveform data
//             _waveformData.add((50 + (timer.tick % 10) * 5).toDouble());
//             if (_waveformData.length > 50) {
//               _waveformData.removeAt(0);
//             }
//           });
//         });
//       }
//     } catch (e) {
//       print('Error starting recording: $e');
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       final path = await _audioRecorder.stop();
//       _timer?.cancel();

//       if (path != null && mounted) {
//         context.read<OnboardingBloc>().add(StopAudioRecording(path));
//       }
//     } catch (e) {
//       print('Error stopping recording: $e');
//     }
//   }

//   Future<void> _cancelRecording() async {
//     try {
//       await _audioRecorder.stop();
//       _timer?.cancel();

//       if (mounted) {
//         context.read<OnboardingBloc>().add(CancelAudioRecording());
//       }
//     } catch (e) {
//       print('Error canceling recording: $e');
//     }
//   }

//   String _formatDuration(int milliseconds) {
//     final seconds = milliseconds ~/ 1000;
//     final minutes = seconds ~/ 60;
//     final remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<OnboardingBloc, OnboardingState>(
//       listener: (context, state) {
//         if (state.isRecordingAudio && _recordDuration == 0) {
//           _startRecording();
//         }
//       },
//       builder: (context, state) {
//         if (state.audioPath != null && !state.isRecordingAudio) {
//           // Show recorded audio
//           return Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1A1A),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: const Color(0xFF2A2A2A),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF10B981).withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.mic,
//                     color: Color(0xFF10B981),
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Audio Recorded',
//                         style: GoogleFonts.spaceGrotesk(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         _formatDuration(_recordDuration),
//                         style: GoogleFonts.spaceGrotesk(
//                           color: const Color(0xFF9CA3AF),
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     context.read<OnboardingBloc>().add(DeleteAudioRecording());
//                     setState(() {
//                       _recordDuration = 0;
//                       _waveformData = [];
//                     });
//                   },
//                   icon: const Icon(
//                     Icons.delete_outline,
//                     color: Color(0xFFEF4444),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (state.isRecordingAudio) {
//           // Show recording UI with waveform
//           return Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1A1A),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: const Color(0xFFEF4444),
//                 width: 2,
//               ),
//             ),
//             child: Column(
//               children: [
//                 // Recording indicator and time
//                 Row(
//                   children: [
//                     AnimatedBuilder(
//                       animation: _animationController,
//                       builder: (context, child) {
//                         return Container(
//                           width: 12,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: Color.lerp(
//                               const Color(0xFFEF4444),
//                               const Color(0xFFEF4444).withOpacity(0.3),
//                               _animationController.value,
//                             ),
//                             shape: BoxShape.circle,
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Recording',
//                       style: GoogleFonts.spaceGrotesk(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       _formatDuration(_recordDuration),
//                       style: GoogleFonts.spaceGrotesk(
//                         color: const Color(0xFF9CA3AF),
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Waveform visualization
//                 Container(
//                   height: 60,
//                   alignment: Alignment.center,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: List.generate(
//                       _waveformData.isEmpty ? 20 : _waveformData.length,
//                       (index) {
//                         final height = _waveformData.isEmpty
//                             ? 20.0
//                             : _waveformData[index];
//                         return Container(
//                           width: 3,
//                           height: height,
//                           margin: const EdgeInsets.symmetric(horizontal: 2),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFEF4444),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Action buttons
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: _cancelRecording,
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.white,
//                           side: const BorderSide(
//                             color: Color(0xFF2A2A2A),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           'Cancel',
//                           style: GoogleFonts.spaceGrotesk(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _stopRecording,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFEF4444),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: Text(
//                           'Stop',
//                           style: GoogleFonts.spaceGrotesk(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         }

//         return const SizedBox.shrink();
//       },
//     );
//   }
// }

// audio_recorder_widget.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({super.key});

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isRecorded = false;
  bool _isPlaying = false;

  String? _filePath;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  StreamSubscription<Amplitude>? _amplitudeSub;
  double _currentAmplitude = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    _filePath =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _filePath!,
    );

    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
      setState(() {
        // Normalize amplitude (range: -160 dB to 0 dB)
        _currentAmplitude = (amp.current + 45).clamp(0, 45) / 45.0;
      });
    });

    setState(() {
      _isRecording = true;
      _isRecorded = false;
      _recordDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration += const Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    _amplitudeSub?.cancel();

    if (path != null) {
      setState(() {
        _filePath = path;
        _isRecording = false;
        _isRecorded = true;
      });
    }
  }

  void _cancelRecording() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    if (_filePath != null) File(_filePath!).deleteSync();
    setState(() {
      _isRecording = false;
      _isRecorded = false;
      _filePath = null;
      _recordDuration = Duration.zero;
      _currentAmplitude = 0;
    });
  }

  Future<void> _playAudio() async {
    if (_filePath == null) return;
    await _audioPlayer.play(DeviceFileSource(_filePath!));
    setState(() => _isPlaying = true);

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _stopAudio() async {
    if (_filePath == null) return;
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);

    // _audioPlayer.onPlayerComplete.listen((_) {
    //   setState(() => _isPlaying = false);
    // });
  }

  Future<void> _deleteAudio() async {
    if (_filePath != null) File(_filePath!).deleteSync();
    setState(() {
      _filePath = null;
      _isRecorded = false;
      _currentAmplitude = 0;
    });
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          // BackdropFilter(
          //   filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          //   child: Container(),
          // ),
          Container(
            decoration: BoxDecoration(
              // border: Border.all(
              //                                 color: Colors.white,
              //                                 width: 1,
              //                               ),
              borderRadius: BorderRadius.circular(14),
              // gradient: const LinearGradient(
              //   begin: Alignment.centerLeft,
              //   end: Alignment.centerRight,
              //   colors: [Color(0xFF101010), Color(0xFFFFFFFF)],
              // ),
            ),
          ),
          Padding(
  padding: const EdgeInsets.all(0.5),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: const RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Color(0xFF444444),
          Color(0xFF222222),
          Color(0xFF444444),
        ],
        stops: [0.5, 1, 2],
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------- TOP ROW --------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status text
              Text(
                _isRecording
                    ? "Recording Audio..."
                    : _isRecorded
                        ? "Audio Recorded"
                        : "Tap to Record",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),

              // Action buttons (Stop / Close / Delete depending on state)
              if (_isRecording) ...[
                Row(
                  children: [
                    _buildControlButton(
                      icon: Icons.stop,
                      color: Color(0xff9196FF),
                      onTap: _stopRecording,
                    ),
                    SizedBox(width: 10,),
                    // IconButton(
                    //   onPressed: _stopRecording,
                    //   icon: const Icon(Icons.stop_circle_rounded, color: Color(0xff9196FF)),
                    //   tooltip: "Stop Recording",
                    // ),
                    _buildControlButton(
                      icon: Icons.close_rounded,
                      color: Color(0xff9196FF),
                      onTap: _cancelRecording,
                    ),
                    // IconButton(
                    //   onPressed: _cancelRecording,
                    //   icon: const Icon(Icons.close_rounded, color: Color(0xff9196FF),),
                    //   tooltip: "Cancel",
                    // ),
                  ],
                ),
              ] else if (_isRecorded) ...[
                Row(
                  children: [
                    Text(
                      _formatTime(_recordDuration),
                      style: const TextStyle(
                        color: Color(0xff9196FF),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _deleteAudio,
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xff9196FF)),
                      tooltip: "Delete Recording",
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // -------------------- SECOND ROW --------------------
          if (_isRecording) ...[
            Row(
              children: [
                // Mic button (active during recording)
                GestureDetector(
                  onTap: () {},
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xff9196FF),
                    child: Icon(Icons.mic, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),

                // Waveform
                Expanded(child: _buildLiveWaveform()),

                const SizedBox(width: 10),

                // Timer
                Text(
                  _formatTime(_recordDuration),
                  style: const TextStyle(
                    color: Color(0xff9196FF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ] else if (_isRecorded) ...[
            Row(
              children: [
                // Play button
                GestureDetector(
                  onTap: _isPlaying ? _stopAudio : _playAudio,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xff5961FF),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Waveform
                Expanded(child: _buildLiveWaveform()),
              ],
            ),
          ] else ...[
            // Idle (tap to record)
            Row(
              children: [
                GestureDetector(
                  onTap: _startRecording,
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xff5961FF),
                    child: Icon(Icons.mic_none, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildLiveWaveform()),
              ],
            ),
          ],
        ],
      ),
    ),
  ),
)

        ],
      ),
    );
  }

  /// 🎵 Builds a waveform that reacts to mic input
  Widget _buildLiveWaveform() {
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(20, (i) {
          // Use amplitude to make bars pulse smoothly
          final height = _isRecording
              ? (Random().nextDouble() * 0.5 + 0.5) *
                  (10 + (_currentAmplitude * 25))
              : (i % 2 == 0 ? 15.0 : 8.0);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }),
      ),
    );
  }
}
