import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/experience.dart';
import '../../repositories/experience_repository.dart';

// Events
abstract class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

class LoadExperiences extends ExperienceEvent {}

class ToggleExperienceSelection extends ExperienceEvent {
  final int experienceId;

  const ToggleExperienceSelection(this.experienceId);

  @override
  List<Object?> get props => [experienceId];
}

class UpdateExperienceText extends ExperienceEvent {
  final String text;

  const UpdateExperienceText(this.text);

  @override
  List<Object?> get props => [text];
}

// States
abstract class ExperienceState extends Equatable {
  const ExperienceState();

  @override
  List<Object?> get props => [];
}

class ExperienceInitial extends ExperienceState {}

class ExperienceLoading extends ExperienceState {}

class ExperienceLoaded extends ExperienceState {
  final List<Experience> experiences;
  final Set<int> selectedExperienceIds;
  final String experienceText;

  const ExperienceLoaded({
    required this.experiences,
    this.selectedExperienceIds = const {},
    this.experienceText = '',
  });

  ExperienceLoaded copyWith({
    List<Experience>? experiences,
    Set<int>? selectedExperienceIds,
    String? experienceText,
  }) {
    return ExperienceLoaded(
      experiences: experiences ?? this.experiences,
      selectedExperienceIds: selectedExperienceIds ?? this.selectedExperienceIds,
      experienceText: experienceText ?? this.experienceText,
    );
  }

  @override
  List<Object?> get props => [experiences, selectedExperienceIds, experienceText];
}

class ExperienceError extends ExperienceState {
  final String message;

  const ExperienceError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final ExperienceRepository repository;

  ExperienceBloc({required this.repository}) : super(ExperienceInitial()) {
    on<LoadExperiences>(_onLoadExperiences);
    on<ToggleExperienceSelection>(_onToggleExperienceSelection);
    on<UpdateExperienceText>(_onUpdateExperienceText);
  }

  Future<void> _onLoadExperiences(
    LoadExperiences event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(ExperienceLoading());
    try {
      final experiences = await repository.getExperiences();
      emit(ExperienceLoaded(experiences: experiences));
    } catch (e) {
      emit(ExperienceError(e.toString()));
    }
  }

  void _onToggleExperienceSelection(
    ToggleExperienceSelection event,
    Emitter<ExperienceState> emit,
  ) {
    if (state is ExperienceLoaded) {
      final currentState = state as ExperienceLoaded;
      final newSelectedIds = Set<int>.from(currentState.selectedExperienceIds);
      
      if (newSelectedIds.contains(event.experienceId)) {
        newSelectedIds.remove(event.experienceId);
      } else {
        newSelectedIds.add(event.experienceId);
      }

      emit(currentState.copyWith(selectedExperienceIds: newSelectedIds));
    }
  }

  void _onUpdateExperienceText(
    UpdateExperienceText event,
    Emitter<ExperienceState> emit,
  ) {
    if (state is ExperienceLoaded) {
      final currentState = state as ExperienceLoaded;
      emit(currentState.copyWith(experienceText: event.text));
    }
  }
}