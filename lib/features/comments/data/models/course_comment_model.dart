import 'package:e_learning/features/comments/domain/entities/course_comment.dart';

class CourseCommentModel extends CourseComment {
  const CourseCommentModel({
    required super.id,
    required super.courseId,
    required super.videoId,
    required super.authorName,
    required super.courseTitle,
    required super.message,
    required super.timeLabel,
    required super.createdAt,
  });

  factory CourseCommentModel.fromJson(Map<String, dynamic> json) {
    return CourseCommentModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      videoId: json['videoId'] as String,
      authorName: json['authorName'] as String,
      courseTitle: json['courseTitle'] as String,
      message: json['message'] as String,
      timeLabel: json['timeLabel'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  CourseCommentModel copyWith({
    String? id,
    String? courseId,
    String? videoId,
    String? authorName,
    String? courseTitle,
    String? message,
    String? timeLabel,
    DateTime? createdAt,
  }) {
    return CourseCommentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      videoId: videoId ?? this.videoId,
      authorName: authorName ?? this.authorName,
      courseTitle: courseTitle ?? this.courseTitle,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
