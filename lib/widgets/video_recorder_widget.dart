import 'dart:async';
import 'dart:io';
import 'package:eightclub_assignment/components/build_control_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart'; 
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
  VideoPlayerController? _videoPlayerController; 
  Timer? _timer;
  int _recordDuration = 0;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isRecording = false;

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _videoPlayerController?.dispose(); 
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
                buildControlButton(
                  icon: Icons.stop_rounded,
                  color: Color(0xff9196FF),
                  onTap: _stopRecording,
                )
              else if (isRecorded)
                buildControlButton(
                  icon: Icons.videocam_rounded,
                  color: const Color(0xFF6D5DFB),
                  onTap: () {
                    if (state.videoPath != null) {
                      _playRecordedVideo(state.videoPath!);
                    }
                  },
                )
              else
                buildControlButton(
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
                buildControlButton(
                  icon: Icons.close_rounded,
                  color: Color(0xff9196FF),
                  onTap: _cancelRecording,
                )
              else if (isRecorded)
                buildControlButton(
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
