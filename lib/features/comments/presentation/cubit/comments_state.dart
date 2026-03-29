import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/comments/domain/entities/course_comment.dart';
import 'package:equatable/equatable.dart';

class CommentsState extends Equatable {
  const CommentsState({
    this.status = ViewStateStatus.initial,
    this.actionStatus = ViewStateStatus.initial,
    this.comments = const [],
    this.courseId,
    this.videoId,
    this.errorMessage,
    this.actionMessage,
  });

  final ViewStateStatus status;
  final ViewStateStatus actionStatus;
  final List<CourseComment> comments;
  final String? courseId;
  final String? videoId;
  final String? errorMessage;
  final String? actionMessage;

  CommentsState copyWith({
    ViewStateStatus? status,
    ViewStateStatus? actionStatus,
    List<CourseComment>? comments,
    String? courseId,
    String? videoId,
    String? errorMessage,
    String? actionMessage,
    bool clearErrorMessage = false,
    bool clearActionMessage = false,
  }) {
    return CommentsState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      comments: comments ?? this.comments,
      courseId: courseId ?? this.courseId,
      videoId: videoId ?? this.videoId,
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
    comments,
    courseId,
    videoId,
    errorMessage,
    actionMessage,
  ];
}
