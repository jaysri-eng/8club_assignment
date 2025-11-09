import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class UpdateQuestionText extends OnboardingEvent {
  final String text;

  const UpdateQuestionText(this.text);

  @override
  List<Object?> get props => [text];
}

class StartAudioRecording extends OnboardingEvent {}

class StopAudioRecording extends OnboardingEvent {
  final String audioPath;

  const StopAudioRecording(this.audioPath);

  @override
  List<Object?> get props => [audioPath];
}

class CancelAudioRecording extends OnboardingEvent {}

class DeleteAudioRecording extends OnboardingEvent {}

class StartVideoRecording extends OnboardingEvent {}

class StopVideoRecording extends OnboardingEvent {
  final String videoPath;

  const StopVideoRecording(this.videoPath);

  @override
  List<Object?> get props => [videoPath];
}

class CancelVideoRecording extends OnboardingEvent {}

class DeleteVideoRecording extends OnboardingEvent {}

class ToggleAudioRecording extends OnboardingEvent {}

class ToggleVideoRecording extends OnboardingEvent {}

// States
class OnboardingState extends Equatable {
  final String questionText;
  final String? audioPath;
  final String? videoPath;
  final bool isRecordingAudio;
  final bool isRecordingVideo;

  const OnboardingState({
    this.questionText = '',
    this.audioPath,
    this.videoPath,
    this.isRecordingAudio = false,
    this.isRecordingVideo = false,
  });

  OnboardingState copyWith({
    String? questionText,
    String? audioPath,
    String? videoPath,
    bool? isRecordingAudio,
    bool? isRecordingVideo,
    bool clearAudio = false,
    bool clearVideo = false,
  }) {
    return OnboardingState(
      questionText: questionText ?? this.questionText,
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
      videoPath: clearVideo ? null : (videoPath ?? this.videoPath),
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
    );
  }

  @override
  List<Object?> get props => [
        questionText,
        audioPath,
        videoPath,
        isRecordingAudio,
        isRecordingVideo,
      ];
}

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<UpdateQuestionText>(_onUpdateQuestionText);
    on<StartAudioRecording>(_onStartAudioRecording);
    on<StopAudioRecording>(_onStopAudioRecording);
    on<CancelAudioRecording>(_onCancelAudioRecording);
    on<DeleteAudioRecording>(_onDeleteAudioRecording);
    on<StartVideoRecording>(_onStartVideoRecording);
    on<StopVideoRecording>(_onStopVideoRecording);
    on<CancelVideoRecording>(_onCancelVideoRecording);
    on<DeleteVideoRecording>(_onDeleteVideoRecording);
    on<ToggleAudioRecording>(_onToggleAudioRecording);
    on<ToggleVideoRecording>(_onToggleVideoRecording);
  }

  void _onUpdateQuestionText(
    UpdateQuestionText event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(questionText: event.text));
  }

  void _onStartAudioRecording(
    StartAudioRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(isRecordingAudio: true));
  }

  void _onStopAudioRecording(
    StopAudioRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      isRecordingAudio: false,
      audioPath: event.audioPath,
    ));
  }

  void _onCancelAudioRecording(
    CancelAudioRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(isRecordingAudio: false));
  }

  void _onDeleteAudioRecording(
    DeleteAudioRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(clearAudio: true));
  }

  void _onStartVideoRecording(
    StartVideoRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(isRecordingVideo: true));
  }

  void _onStopVideoRecording(
    StopVideoRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      isRecordingVideo: false,
      videoPath: event.videoPath,
    ));
  }

  void _onCancelVideoRecording(
    CancelVideoRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(isRecordingVideo: false));
  }

  void _onDeleteVideoRecording(
    DeleteVideoRecording event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(clearVideo: true));
  }

  void _onToggleAudioRecording(
    ToggleAudioRecording event,
    Emitter<OnboardingState> emit,
  ) {
    final isActive = state.isRecordingAudio;
    emit(state.copyWith(
      isRecordingAudio: !isActive,
      audioPath: isActive ? null : state.audioPath,
    ));
  }

  void _onToggleVideoRecording(
    ToggleVideoRecording event,
    Emitter<OnboardingState> emit,
  ) {
    final isActive = state.isRecordingVideo;
    emit(state.copyWith(
      isRecordingVideo: !isActive,
      videoPath: isActive ? null : state.videoPath,
    ));
  }
}