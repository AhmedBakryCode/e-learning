import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:equatable/equatable.dart';

class ProgressState extends Equatable {
  const ProgressState({
    this.status = ViewStateStatus.initial,
    this.actionStatus = ViewStateStatus.initial,
    this.progressItems = const [],
    this.studentIdFilter,
    this.errorMessage,
    this.actionMessage,
  });

  final ViewStateStatus status;
  final ViewStateStatus actionStatus;
  final List<LearningProgress> progressItems;
  final String? studentIdFilter;
  final String? errorMessage;
  final String? actionMessage;

  ProgressState copyWith({
    ViewStateStatus? status,
    ViewStateStatus? actionStatus,
    List<LearningProgress>? progressItems,
    String? studentIdFilter,
    String? errorMessage,
    String? actionMessage,
    bool clearErrorMessage = false,
    bool clearActionMessage = false,
  }) {
    return ProgressState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      progressItems: progressItems ?? this.progressItems,
      studentIdFilter: studentIdFilter ?? this.studentIdFilter,
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
    progressItems,
    studentIdFilter,
    errorMessage,
    actionMessage,
  ];
}
