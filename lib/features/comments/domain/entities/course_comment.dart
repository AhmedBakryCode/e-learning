import 'package:equatable/equatable.dart';

class CourseComment extends Equatable {
  const CourseComment({
    required this.id,
    required this.courseId,
    required this.videoId,
    required this.authorName,
    required this.courseTitle,
    required this.message,
    required this.timeLabel,
    required this.createdAt,
  });

  final String id;
  final String courseId;
  final String videoId;
  final String authorName;
  final String courseTitle;
  final String message;
  final String timeLabel;
  final DateTime createdAt;

  CourseComment copyWith({
    String? id,
    String? courseId,
    String? videoId,
    String? authorName,
    String? courseTitle,
    String? message,
    String? timeLabel,
    DateTime? createdAt,
  }) {
    return CourseComment(
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

  @override
  List<Object?> get props => [
    id,
    courseId,
    videoId,
    authorName,
    courseTitle,
    message,
    timeLabel,
    createdAt,
  ];
}
