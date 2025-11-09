import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:eightclub_assignment/components/build_control_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  top row
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

                        // Action buttons (stop/close/delete )
                        if (_isRecording) ...[
                          Row(
                            children: [
                              buildControlButton(
                                icon: Icons.stop,
                                color: Color(0xff9196FF),
                                onTap: _stopRecording,
                              ),
                              SizedBox(width: 10),
                              buildControlButton(
                                icon: Icons.close_rounded,
                                color: Color(0xff9196FF),
                                onTap: _cancelRecording,
                              ),
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
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xff9196FF),
                                ),
                                tooltip: "Delete Recording",
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    //  second row
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
          ),
        ],
      ),
    );
  }

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
