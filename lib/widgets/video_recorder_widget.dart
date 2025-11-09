// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:camera/camera.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../blocs/onboarding/onboarding_bloc.dart';

// class VideoRecorderWidget extends StatefulWidget {
//   const VideoRecorderWidget({super.key});

//   @override
//   State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
// }

// class _VideoRecorderWidgetState extends State<VideoRecorderWidget>
//     with SingleTickerProviderStateMixin {
//   CameraController? _cameraController;
//   Timer? _timer;
//   int _recordDuration = 0;
//   late AnimationController _animationController;
//   bool _isInitialized = false;

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
//     _cameraController?.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       // Request permissions
//       final cameraStatus = await Permission.camera.request();
//       final micStatus = await Permission.microphone.request();

//       if (cameraStatus.isGranted && micStatus.isGranted) {
//         final cameras = await availableCameras();
//         if (cameras.isEmpty) return;

//         _cameraController = CameraController(
//           cameras.first,
//           ResolutionPreset.high,
//           enableAudio: true,
//         );

//         await _cameraController!.initialize();
        
//         if (mounted) {
//           setState(() {
//             _isInitialized = true;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error initializing camera: $e');
//     }
//   }

//   Future<void> _startRecording() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       await _initializeCamera();
//     }

//     if (_cameraController != null && _cameraController!.value.isInitialized) {
//       try {
//         await _cameraController!.startVideoRecording();

//         setState(() {
//           _recordDuration = 0;
//         });

//         _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//           if (mounted) {
//             setState(() {
//               _recordDuration++;
//             });
//           }
//         });
//       } catch (e) {
//         print('Error starting video recording: $e');
//       }
//     }
//   }

//   Future<void> _stopRecording() async {
//     if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
//       try {
//         final videoFile = await _cameraController!.stopVideoRecording();
//         _timer?.cancel();

//         if (mounted) {
//           context
//               .read<OnboardingBloc>()
//               .add(StopVideoRecording(videoFile.path));
//         }
//       } catch (e) {
//         print('Error stopping video recording: $e');
//       }
//     }
//   }

//   Future<void> _cancelRecording() async {
//     if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
//       try {
//         await _cameraController!.stopVideoRecording();
//         _timer?.cancel();

//         if (mounted) {
//           context.read<OnboardingBloc>().add(CancelVideoRecording());
//         }
//       } catch (e) {
//         print('Error canceling video recording: $e');
//       }
//     }
//   }

//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<OnboardingBloc, OnboardingState>(
//       listener: (context, state) {
//         if (state.isRecordingVideo && _recordDuration == 0) {
//           _startRecording();
//         }
//       },
//       builder: (context, state) {
//         if (state.videoPath != null && !state.isRecordingVideo) {
//           // Show recorded video
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
//                     Icons.videocam,
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
//                         'Video Recorded',
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
//                     context.read<OnboardingBloc>().add(DeleteVideoRecording());
//                     setState(() {
//                       _recordDuration = 0;
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

//         if (state.isRecordingVideo) {
//           // Show recording UI with camera preview
//           return Container(
//             height: 280,
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1A1A),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: const Color(0xFFEF4444),
//                 width: 2,
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Stack(
//                 children: [
//                   // Camera Preview
//                   if (_isInitialized && _cameraController != null)
//                     Positioned.fill(
//                       child: CameraPreview(_cameraController!),
//                     )
//                   else
//                     Container(
//                       color: Colors.black,
//                       child: const Center(
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),

//                   // Recording overlay
//                   Positioned.fill(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.black.withOpacity(0.5),
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.7),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Recording indicator
//                   Positioned(
//                     top: 16,
//                     left: 16,
//                     child: Row(
//                       children: [
//                         AnimatedBuilder(
//                           animation: _animationController,
//                           builder: (context, child) {
//                             return Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: Color.lerp(
//                                   const Color(0xFFEF4444),
//                                   const Color(0xFFEF4444).withOpacity(0.3),
//                                   _animationController.value,
//                                 ),
//                                 shape: BoxShape.circle,
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             _formatDuration(_recordDuration),
//                             style: GoogleFonts.spaceGrotesk(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Action buttons
//                   Positioned(
//                     bottom: 16,
//                     left: 16,
//                     right: 16,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: _cancelRecording,
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               backgroundColor: Colors.black.withOpacity(0.5),
//                               side: const BorderSide(
//                                 color: Colors.white,
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Text(
//                               'Cancel',
//                               style: GoogleFonts.spaceGrotesk(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _stopRecording,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFEF4444),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: Text(
//                               'Stop',
//                               style: GoogleFonts.spaceGrotesk(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return const SizedBox.shrink();
//       },
//     );
//   }
// }


// video_recorder_widget.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:camera/camera.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/onboarding/onboarding_bloc.dart';
// import 'glass_container.dart';

// class VideoRecorderWidget extends StatefulWidget {
//   const VideoRecorderWidget({super.key});

//   @override
//   State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
// }

// class _VideoRecorderWidgetState extends State<VideoRecorderWidget>
//     with SingleTickerProviderStateMixin {
//   CameraController? _cameraController;
//   Timer? _timer;
//   int _recordDuration = 0;
//   bool _isInitialized = false;
//   bool _isPlaying = false;
//   bool _isRecording = false;

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeCamera() async {
//     final camStatus = await Permission.camera.request();
//     final micStatus = await Permission.microphone.request();

//     if (!camStatus.isGranted || !micStatus.isGranted) return;

//     final cameras = await availableCameras();
//     if (cameras.isEmpty) return;

//     _cameraController = CameraController(
//       cameras.first,
//       ResolutionPreset.medium,
//       enableAudio: true,
//     );

//     await _cameraController!.initialize();
//     setState(() => _isInitialized = true);
//   }

//   Future<void> _startRecording() async {
//     if (!_isInitialized) await _initializeCamera();

//     await _cameraController?.startVideoRecording();
//     setState(() {
//       _recordDuration = 0;
//       _isRecording = true;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted) setState(() => _recordDuration++);
//     });
//   }

//   Future<void> _stopRecording() async {
//     if (!(_cameraController?.value.isRecordingVideo ?? false)) return;

//     final videoFile = await _cameraController!.stopVideoRecording();
//     _timer?.cancel();

//     if (mounted) {
//       setState(() => _isRecording = false);
//       context.read<OnboardingBloc>().add(StopVideoRecording(videoFile.path));
//     }
//   }

//   Future<void> _cancelRecording() async {
//     if (_cameraController?.value.isRecordingVideo ?? false) {
//       await _cameraController!.stopVideoRecording();
//     }

//     _timer?.cancel();
//     setState(() {
//       _recordDuration = 0;
//       _isRecording = false;
//     });

//     if (mounted) context.read<OnboardingBloc>().add(CancelVideoRecording());
//   }

//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.9),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.white, size: 22),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<OnboardingBloc, OnboardingState>(
//       listener: (context, state) {},
//       builder: (context, state) {
//         final isRecorded = state.videoPath != null && !_isRecording;

//         return GlassContainer(
//           blur: 15,
//           borderWidth: 0.5,
//           borderGradient: const LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: [Color(0xFF6D5DFB), Color(0xFF9E8CFC)],
//           ),
//           child: Row(
//             children: [
//               if (_isRecording)
//                 _buildControlButton(
//                   icon: Icons.stop_rounded,
//                   color: Colors.redAccent,
//                   onTap: _stopRecording,
//                 )
//               else if (isRecorded)
//                 _buildControlButton(
//                   icon: Icons.play_arrow_rounded,
//                   color: const Color(0xFF6D5DFB),
//                   onTap: () {
//                     // TODO: Integrate video playback logic here
//                     setState(() => _isPlaying = !_isPlaying);
//                   },
//                 )
//               else
//                 _buildControlButton(
//                   icon: Icons.videocam_rounded,
//                   color: const Color(0xFF6D5DFB),
//                   onTap: _startRecording,
//                 ),

//               const SizedBox(width: 14),

//               // Recording or Recorded text
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _isRecording
//                           ? "Recording Video..."
//                           : isRecorded
//                               ? "Video Recorded"
//                               : "Ready to Record",
//                       style: GoogleFonts.spaceGrotesk(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatDuration(_recordDuration),
//                       style: GoogleFonts.spaceGrotesk(
//                         color: Colors.white70,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Cancel / Delete button
//               if (_isRecording)
//                 _buildControlButton(
//                   icon: Icons.close_rounded,
//                   color: Colors.grey,
//                   onTap: _cancelRecording,
//                 )
//               else if (isRecorded)
//                 _buildControlButton(
//                   icon: Icons.delete_outline_rounded,
//                   color: Colors.grey,
//                   onTap: () {
//                     context.read<OnboardingBloc>().add(DeleteVideoRecording());
//                     setState(() {
//                       _recordDuration = 0;
//                       _isRecording = false;
//                     });
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart'; // ✅ added
import '../blocs/onboarding/onboarding_bloc.dart';
import 'glass_container.dart';

class VideoRecorderWidget extends StatefulWidget {
  const VideoRecorderWidget({super.key});

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController; // ✅ added
  Timer? _timer;
  int _recordDuration = 0;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isRecording = false;

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _videoPlayerController?.dispose(); // ✅ added
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!camStatus.isGranted || !micStatus.isGranted) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    await _cameraController!.initialize();
    setState(() => _isInitialized = true);
  }

  Future<void> _startRecording() async {
    if (!_isInitialized) await _initializeCamera();

    await _cameraController?.startVideoRecording();
    setState(() {
      _recordDuration = 0;
      _isRecording = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordDuration++);
    });
  }

  Future<void> _stopRecording() async {
    if (!(_cameraController?.value.isRecordingVideo ?? false)) return;

    final videoFile = await _cameraController!.stopVideoRecording();
    _timer?.cancel();

    if (mounted) {
      setState(() => _isRecording = false);
      context.read<OnboardingBloc>().add(StopVideoRecording(videoFile.path));
    }
  }

  Future<void> _cancelRecording() async {
    if (_cameraController?.value.isRecordingVideo ?? false) {
      await _cameraController!.stopVideoRecording();
    }

    _timer?.cancel();
    setState(() {
      _recordDuration = 0;
      _isRecording = false;
    });

    if (mounted) context.read<OnboardingBloc>().add(CancelVideoRecording());
  }

  Future<void> _playRecordedVideo(String path) async {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(File(path));

    await _videoPlayerController!.initialize();
    await _videoPlayerController!.play();

    setState(() => _isPlaying = true);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () {
                  _videoPlayerController?.pause();
                  Navigator.pop(context);
                  setState(() => _isPlaying = false);
                },
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      _videoPlayerController?.pause();
      setState(() => _isPlaying = false);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {},
      builder: (context, state) {
        final isRecorded = state.videoPath != null && !_isRecording;

        return GlassContainer(
          blur: 15,
          borderWidth: 0.5,
          borderGradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF6D5DFB), Color(0xFF9E8CFC)],
          ),
          child: Row(
            children: [
              if (_isRecording)
                _buildControlButton(
                  icon: Icons.stop_rounded,
                  color: Color(0xff9196FF),
                  onTap: _stopRecording,
                )
              else if (isRecorded)
                _buildControlButton(
                  icon: Icons.videocam_rounded,
                  color: const Color(0xFF6D5DFB),
                  onTap: () {
                    if (state.videoPath != null) {
                      _playRecordedVideo(state.videoPath!);
                    }
                  },
                )
              else
                _buildControlButton(
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFF6D5DFB),
                  onTap: _startRecording,
                ),

              const SizedBox(width: 14),

              // Recording or Recorded text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRecording
                          ? "Recording Video..."
                          : isRecorded
                              ? "Video Recorded"
                              : "Ready to Record",
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(_recordDuration),
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Cancel / Delete button
              if (_isRecording)
                _buildControlButton(
                  icon: Icons.close_rounded,
                  color: Color(0xff9196FF),
                  onTap: _cancelRecording,
                )
              else if (isRecorded)
                _buildControlButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.grey,
                  onTap: () {
                    context.read<OnboardingBloc>().add(DeleteVideoRecording());
                    setState(() {
                      _recordDuration = 0;
                      _isRecording = false;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
