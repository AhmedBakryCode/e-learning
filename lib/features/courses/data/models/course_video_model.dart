import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';

String _normalizeVideoUrl(String videoUrl) {
  // If it's an asset or already a full external URL, return as-is
  if (videoUrl.startsWith('assets/')) {
    return videoUrl;
  }

  String path;

  // If URL starts with http:// or https://, extract path from /uploads onwards
  if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
    final uploadsIndex = videoUrl.indexOf('/uploads');
    if (uploadsIndex != -1) {
      path = videoUrl.substring(uploadsIndex);
    } else {
      // No /uploads found, use the URL as-is
      return videoUrl;
    }
  } else if (videoUrl.startsWith('uploads/')) {
    // URL already starts with uploads/, use as-is
    path = '/$videoUrl';
  } else {
    // Unknown format, return as-is
    return videoUrl;
  }

  // Prepend base URL (without /api/v1 since uploads is at root)
  final baseUrl = EndpointConstants.baseUrl;
  // Remove /api/v1 from base URL to get the host URL
  final hostUrl = baseUrl.replaceAll('/api/v1', '');
  return '$hostUrl$path';
}

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
    final rawVideoUrl = json['videoUrl'] as String;
    return CourseVideoModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: _normalizeVideoUrl(rawVideoUrl),
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
