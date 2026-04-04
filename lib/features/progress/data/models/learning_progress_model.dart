import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';

class LearningProgressModel extends LearningProgress {
  const LearningProgressModel({
    required super.id,
    required super.studentId,
    required super.courseId,
    required super.courseTitle,
    required super.completionPercent,
    required super.currentLesson,
    required super.totalLessons,
    super.watchedVideos,
    super.lastVideoId,
    super.lastVideoTitle,
  });

  factory LearningProgressModel.fromJson(Map<String, dynamic> json) {
    return LearningProgressModel(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String,
      completionPercent: (json['completionPercent'] as num).toDouble(),
      currentLesson: json['currentLesson'] as int,
      totalLessons: json['totalLessons'] as int,
      watchedVideos: (json['watchedVideos'] as num?)?.toInt() ?? 0,
      lastVideoId: json['lastVideoId'] as String?,
      lastVideoTitle: json['lastVideoTitle'] as String?,
    );
  }

  @override
  LearningProgressModel copyWith({
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
    return LearningProgressModel(
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
}
