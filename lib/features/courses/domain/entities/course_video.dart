import 'package:equatable/equatable.dart';

class CourseVideo extends Equatable {
  const CourseVideo({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.duration,
    required this.progress,
    this.isPreview = false,
    this.isUploaded = true,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final String videoUrl;
  final String duration;
  final double progress;
  final bool isPreview;
  final bool isUploaded;

  CourseVideo copyWith({
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
    return CourseVideo(
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

  @override
  List<Object?> get props => [
    id,
    courseId,
    title,
    description,
    videoUrl,
    duration,
    progress,
    isPreview,
    isUploaded,
  ];
}
