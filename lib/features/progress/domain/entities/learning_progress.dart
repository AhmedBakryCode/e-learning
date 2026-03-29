import 'package:equatable/equatable.dart';

class LearningProgress extends Equatable {
  const LearningProgress({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseTitle,
    required this.completionPercent,
    required this.currentLesson,
    required this.totalLessons,
    this.watchedVideos = 0,
    this.lastVideoId,
    this.lastVideoTitle,
  });

  final String id;
  final String studentId;
  final String courseId;
  final String courseTitle;
  final double completionPercent;
  final int currentLesson;
  final int totalLessons;
  final int watchedVideos;
  final String? lastVideoId;
  final String? lastVideoTitle;

  LearningProgress copyWith({
    String? id,
    String? studentId,
    String? courseId,
    String? courseTitle,
    double? completionPercent,
    int? currentLesson,
    int? totalLessons,
    int? watchedVideos,
    String? lastVideoId,
    String? lastVideoTitle,
  }) {
    return LearningProgress(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      completionPercent: completionPercent ?? this.completionPercent,
      currentLesson: currentLesson ?? this.currentLesson,
      totalLessons: totalLessons ?? this.totalLessons,
      watchedVideos: watchedVideos ?? this.watchedVideos,
      lastVideoId: lastVideoId ?? this.lastVideoId,
      lastVideoTitle: lastVideoTitle ?? this.lastVideoTitle,
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    courseId,
    courseTitle,
    completionPercent,
    currentLesson,
    totalLessons,
    watchedVideos,
    lastVideoId,
    lastVideoTitle,
  ];
}
