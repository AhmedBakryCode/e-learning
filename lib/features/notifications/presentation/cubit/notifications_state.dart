import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:equatable/equatable.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = ViewStateStatus.initial,
    this.actionStatus = ViewStateStatus.initial,
    this.notifications = const [],
    this.isLive = false,
    this.errorMessage,
    this.actionMessage,
  });

  final ViewStateStatus status;
  final ViewStateStatus actionStatus;
  final List<LearningNotification> notifications;
  final bool isLive;
  final String? errorMessage;
  final String? actionMessage;

  NotificationsState copyWith({
    ViewStateStatus? status,
    ViewStateStatus? actionStatus,
    List<LearningNotification>? notifications,
    bool? isLive,
    String? errorMessage,
    String? actionMessage,
    bool clearErrorMessage = false,
    bool clearActionMessage = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      notifications: notifications ?? this.notifications,
      isLive: isLive ?? this.isLive,
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
    notifications,
    isLive,
    errorMessage,
    actionMessage,
  ];
}
