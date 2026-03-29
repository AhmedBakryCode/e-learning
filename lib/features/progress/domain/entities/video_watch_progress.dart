import 'package:equatable/equatable.dart';

class VideoWatchProgress extends Equatable {
  const VideoWatchProgress({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.videoId,
    required this.watchedSeconds,
    required this.totalDurationSeconds,
    required this.isCompleted,
    this.lastWatchedAt,
  });

  final String id;
  final String studentId;
  final String courseId;
  final String videoId;
  final int watchedSeconds;
  final int totalDurationSeconds;
  final bool isCompleted;
  final DateTime? lastWatchedAt;

  double get watchedFraction {
    if (totalDurationSeconds <= 0) {
      return isCompleted ? 1 : 0;
    }

    return (watchedSeconds / totalDurationSeconds).clamp(0, 1);
  }

  VideoWatchProgress copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? videoId,
    int? watchedSeconds,
    int? totalDurationSeconds,
    bool? isCompleted,
    DateTime? lastWatchedAt,
  }) {
    return VideoWatchProgress(
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

  @override
  List<Object?> get props => [
    id,
    studentId,
    courseId,
    videoId,
    watchedSeconds,
    totalDurationSeconds,
    isCompleted,
    lastWatchedAt,
  ];
}
