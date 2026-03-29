import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';
import 'package:equatable/equatable.dart';

class VideoSessionState extends Equatable {
  const VideoSessionState({
    this.status = ViewStateStatus.initial,
    this.actionStatus = ViewStateStatus.initial,
    this.course,
    this.videos = const [],
    this.videoProgress = const [],
    this.currentVideo,
    this.resumePositionSeconds = 0,
    this.courseProgressPercent = 0,
    this.errorMessage,
    this.actionMessage,
  });

  final ViewStateStatus status;
  final ViewStateStatus actionStatus;
  final Course? course;
  final List<CourseVideo> videos;
  final List<VideoWatchProgress> videoProgress;
  final CourseVideo? currentVideo;
  final int resumePositionSeconds;
  final double courseProgressPercent;
  final String? errorMessage;
  final String? actionMessage;

  bool get isCurrentVideoCompleted {
    final index = videoProgress.indexWhere(
      (entry) => entry.videoId == currentVideo?.id,
    );
    final item = index == -1 ? null : videoProgress[index];
    return item?.isCompleted ?? false;
  }

  VideoSessionState copyWith({
    ViewStateStatus? status,
    ViewStateStatus? actionStatus,
    Course? course,
    List<CourseVideo>? videos,
    List<VideoWatchProgress>? videoProgress,
    CourseVideo? currentVideo,
    int? resumePositionSeconds,
    double? courseProgressPercent,
    String? errorMessage,
    String? actionMessage,
    bool clearErrorMessage = false,
    bool clearActionMessage = false,
  }) {
    return VideoSessionState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      course: course ?? this.course,
      videos: videos ?? this.videos,
      videoProgress: videoProgress ?? this.videoProgress,
      currentVideo: currentVideo ?? this.currentVideo,
      resumePositionSeconds:
          resumePositionSeconds ?? this.resumePositionSeconds,
      courseProgressPercent:
          courseProgressPercent ?? this.courseProgressPercent,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    actionStatus,
    course,
    videos,
    videoProgress,
    currentVideo,
    resumePositionSeconds,
    courseProgressPercent,
    errorMessage,
    actionMessage,
  ];
}
