import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:equatable/equatable.dart';

class StudentCourseState extends Equatable {
  const StudentCourseState({
    this.status = ViewStateStatus.initial,
    this.course,
    this.videos = const [],
    this.progress,
    this.lastWatchedVideoId,
    this.errorMessage,
  });

  final ViewStateStatus status;
  final Course? course;
  final List<CourseVideo> videos;
  final LearningProgress? progress;
  final String? lastWatchedVideoId;
  final String? errorMessage;

  String? get resumeVideoId {
    if (lastWatchedVideoId != null) {
      return lastWatchedVideoId;
    }
    if (videos.isEmpty) {
      return null;
    }
    final firstIncomplete = videos
        .where((video) => video.progress < 1)
        .toList();
    return firstIncomplete.isEmpty ? videos.first.id : firstIncomplete.first.id;
  }

  StudentCourseState copyWith({
    ViewStateStatus? status,
    Course? course,
    List<CourseVideo>? videos,
    LearningProgress? progress,
    String? lastWatchedVideoId,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return StudentCourseState(
      status: status ?? this.status,
      course: course ?? this.course,
      videos: videos ?? this.videos,
      progress: progress ?? this.progress,
      lastWatchedVideoId: lastWatchedVideoId ?? this.lastWatchedVideoId,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    course,
    videos,
    progress,
    lastWatchedVideoId,
    errorMessage,
  ];
}
