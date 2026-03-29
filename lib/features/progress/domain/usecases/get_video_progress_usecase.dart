import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';

class GetVideoProgressParams extends Equatable {
  const GetVideoProgressParams({
    required this.studentId,
    required this.courseId,
  });

  final String studentId;
  final String courseId;

  @override
  List<Object?> get props => [studentId, courseId];
}

class GetVideoProgressUseCase
    implements UseCase<List<VideoWatchProgress>, GetVideoProgressParams> {
  const GetVideoProgressUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<List<VideoWatchProgress>> call(GetVideoProgressParams params) {
    return _repository.getVideoProgress(
      studentId: params.studentId,
      courseId: params.courseId,
    );
  }
}
