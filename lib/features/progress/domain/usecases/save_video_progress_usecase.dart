import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';

class SaveVideoProgressParams extends Equatable {
  const SaveVideoProgressParams({
    required this.studentId,
    required this.courseId,
    required this.videoId,
    required this.watchedSeconds,
  });

  final String studentId;
  final String courseId;
  final String videoId;
  final int watchedSeconds;

  @override
  List<Object?> get props => [studentId, courseId, videoId, watchedSeconds];
}

class SaveVideoProgressUseCase
    implements UseCase<VideoWatchProgress, SaveVideoProgressParams> {
  const SaveVideoProgressUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<VideoWatchProgress> call(SaveVideoProgressParams params) {
    return _repository.saveVideoProgress(
      studentId: params.studentId,
      courseId: params.courseId,
      videoId: params.videoId,
      watchedSeconds: params.watchedSeconds,
    );
  }
}
