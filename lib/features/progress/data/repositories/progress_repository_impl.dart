import 'package:e_learning/features/progress/data/datasources/progress_data_source.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl({required ProgressDataSource dataSource})
    : _dataSource = dataSource;

  final ProgressDataSource _dataSource;

  @override
  Future<List<LearningProgress>> getProgressItems({String? studentId}) {
    return _dataSource.getProgressItems(studentId: studentId);
  }

  @override
  Future<LearningProgress> enrollInCourse({
    required String studentId,
    required String courseId,
  }) {
    return _dataSource.enrollInCourse(
      studentId: studentId,
      courseId: courseId,
    );
  }

  @override
  Future<LearningProgress> updateProgress({
    required String progressId,
    required double completionPercent,
    required int currentLesson,
  }) {
    return _dataSource.updateProgress(
      progressId: progressId,
      completionPercent: completionPercent,
      currentLesson: currentLesson,
    );
  }

  @override
  Future<List<VideoWatchProgress>> getVideoProgress({
    required String studentId,
    required String courseId,
  }) {
    return _dataSource.getVideoProgress(
      studentId: studentId,
      courseId: courseId,
    );
  }

  @override
  Future<VideoWatchProgress> saveVideoProgress({
    required String studentId,
    required String courseId,
    required String videoId,
    required int watchedSeconds,
  }) {
    return _dataSource.saveVideoProgress(
      studentId: studentId,
      courseId: courseId,
      videoId: videoId,
      watchedSeconds: watchedSeconds,
    );
  }

  @override
  Future<VideoWatchProgress> markVideoCompleted({
    required String studentId,
    required String courseId,
    required String videoId,
  }) {
    return _dataSource.markVideoCompleted(
      studentId: studentId,
      courseId: courseId,
      videoId: videoId,
    );
  }
}
