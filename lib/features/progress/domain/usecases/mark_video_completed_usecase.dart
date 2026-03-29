import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';

class MarkVideoCompletedParams extends Equatable {
  const MarkVideoCompletedParams({
    required this.studentId,
    required this.courseId,
    required this.videoId,
  });

  final String studentId;
  final String courseId;
  final String videoId;

  @override
  List<Object?> get props => [studentId, courseId, videoId];
}

class MarkVideoCompletedUseCase
    implements UseCase<VideoWatchProgress, MarkVideoCompletedParams> {
  const MarkVideoCompletedUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<VideoWatchProgress> call(MarkVideoCompletedParams params) {
    return _repository.markVideoCompleted(
      studentId: params.studentId,
      courseId: params.courseId,
      videoId: params.videoId,
    );
  }
}
