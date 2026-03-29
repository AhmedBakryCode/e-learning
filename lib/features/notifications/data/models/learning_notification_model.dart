import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';

class LearningNotificationModel extends LearningNotification {
  const LearningNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.timeLabel,
    required super.isRead,
    super.audienceLabel,
    super.zoomMeetingLink,
  });

  @override
  LearningNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeLabel,
    bool? isRead,
    String? audienceLabel,
    String? zoomMeetingLink,
  }) {
    return LearningNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      isRead: isRead ?? this.isRead,
      audienceLabel: audienceLabel ?? this.audienceLabel,
      zoomMeetingLink: zoomMeetingLink ?? this.zoomMeetingLink,
    );
  }
}
