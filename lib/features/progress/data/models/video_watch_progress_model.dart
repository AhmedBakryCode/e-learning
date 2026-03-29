import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';

class VideoWatchProgressModel extends VideoWatchProgress {
  const VideoWatchProgressModel({
    required super.id,
    required super.studentId,
    required super.courseId,
    required super.videoId,
    required super.watchedSeconds,
    required super.totalDurationSeconds,
    required super.isCompleted,
    super.lastWatchedAt,
  });

  @override
  VideoWatchProgressModel copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? videoId,
    int? watchedSeconds,
    int? totalDurationSeconds,
    bool? isCompleted,
    DateTime? lastWatchedAt,
  }) {
    return VideoWatchProgressModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      videoId: videoId ?? this.videoId,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    );
  }
}
