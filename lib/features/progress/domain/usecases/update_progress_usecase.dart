import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateProgressParams extends Equatable {
  const UpdateProgressParams({
    required this.progressId,
    required this.completionPercent,
    required this.currentLesson,
  });

  final String progressId;
  final double completionPercent;
  final int currentLesson;

  @override
  List<Object?> get props => [progressId, completionPercent, currentLesson];
}

class UpdateProgressUseCase
    implements UseCase<LearningProgress, UpdateProgressParams> {
  const UpdateProgressUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<LearningProgress> call(UpdateProgressParams params) {
    return _repository.updateProgress(
      progressId: params.progressId,
      completionPercent: params.completionPercent,
      currentLesson: params.currentLesson,
    );
  }
}
