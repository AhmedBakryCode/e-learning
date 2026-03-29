import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';

abstract class ProgressRepository {
  Future<List<LearningProgress>> getProgressItems({String? studentId});

  Future<LearningProgress> enrollInCourse({
    required String studentId,
    required String courseId,
  });

  Future<LearningProgress> updateProgress({
    required String progressId,
    required double completionPercent,
    required int currentLesson,
  });

  Future<List<VideoWatchProgress>> getVideoProgress({
    required String studentId,
    required String courseId,
  });

  Future<VideoWatchProgress> saveVideoProgress({
    required String studentId,
    required String courseId,
    required String videoId,
    required int watchedSeconds,
  });

  Future<VideoWatchProgress> markVideoCompleted({
    required String studentId,
    required String courseId,
    required String videoId,
  });
}
