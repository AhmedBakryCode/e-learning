import 'package:e_learning/features/courses/domain/entities/course_video.dart';

class CourseVideoModel extends CourseVideo {
  const CourseVideoModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.description,
    required super.videoUrl,
    required super.duration,
    required super.progress,
    super.isPreview,
    super.isUploaded,
  });

  factory CourseVideoModel.fromJson(Map<String, dynamic> json) {
    return CourseVideoModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      duration: json['duration'] as String,
      progress: (json['progress'] as num).toDouble(),
      isPreview: json['isPreview'] as bool? ?? false,
      isUploaded: json['isUploaded'] as bool? ?? true,
    );
  }

  @override
  CourseVideoModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? videoUrl,
    String? duration,
    double? progress,
    bool? isPreview,
    bool? isUploaded,
  }) {
    return CourseVideoModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      isPreview: isPreview ?? this.isPreview,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'duration': duration,
      'progress': progress,
      'isPreview': isPreview,
      'isUploaded': isUploaded,
    };
  }
}
