import 'package:equatable/equatable.dart';

class LearningNotification extends Equatable {
  const LearningNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.isRead,
    this.audienceLabel = 'All students',
    this.zoomMeetingLink,
    this.targetCourseId,
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final bool isRead;
  final String audienceLabel;
  final String? zoomMeetingLink;
  final String? targetCourseId;
  final String? createdAt;

  LearningNotification copyWith({
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
    return LearningNotification(
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

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    timeLabel,
    isRead,
    audienceLabel,
    zoomMeetingLink,
    targetCourseId,
    createdAt,
  ];
}
