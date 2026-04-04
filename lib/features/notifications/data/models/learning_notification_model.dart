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
    super.targetCourseId,
    super.createdAt,
  });

  factory LearningNotificationModel.fromJson(Map<String, dynamic> json) {
    return LearningNotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timeLabel: json['timeLabel'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      audienceLabel: json['audienceLabel'] as String? ?? 'All students',
      zoomMeetingLink: json['zoomMeetingLink'] as String?,
      targetCourseId: json['targetCourseId'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  @override
  LearningNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeLabel,
    bool? isRead,
    String? audienceLabel,
    String? zoomMeetingLink,
    String? targetCourseId,
    String? createdAt,
  }) {
    return LearningNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      isRead: isRead ?? this.isRead,
      audienceLabel: audienceLabel ?? this.audienceLabel,
      zoomMeetingLink: zoomMeetingLink ?? this.zoomMeetingLink,
      targetCourseId: targetCourseId ?? this.targetCourseId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
