import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/notifications/data/models/learning_notification_model.dart';
import 'dart:async';

abstract class NotificationsDataSource {
  Future<List<LearningNotificationModel>> getNotifications();

  Stream<List<LearningNotificationModel>> watchNotifications();

  Future<LearningNotificationModel> createNotification({
    required String title,
    required String message,
    required String zoomMeetingLink,
    String? targetCourseId,
  });
}

class MockNotificationsDataSource implements NotificationsDataSource {
  const MockNotificationsDataSource();

  static final StreamController<List<LearningNotificationModel>> _controller =
      StreamController<List<LearningNotificationModel>>.broadcast();

  @override
  Future<List<LearningNotificationModel>> getNotifications() async {
    await Future<void>.delayed(AppDurations.short);

    return List<LearningNotificationModel>.from(_notifications);
  }

  @override
  Stream<List<LearningNotificationModel>> watchNotifications() async* {
    yield List<LearningNotificationModel>.from(_notifications);
    yield* _controller.stream;
  }

  @override
  Future<LearningNotificationModel> createNotification({
    required String title,
    required String message,
    required String zoomMeetingLink,
    String? targetCourseId,
  }) async {
    await Future<void>.delayed(AppDurations.medium);

    final notification = LearningNotificationModel(
      id: 'notification-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timeLabel: 'Just now',
      isRead: false,
      audienceLabel: targetCourseId != null ? 'Course: $targetCourseId' : 'All students',
      zoomMeetingLink: zoomMeetingLink,
    );

    _notifications.insert(0, notification);
    _controller.add(List<LearningNotificationModel>.from(_notifications));
    return notification;
  }

  static final List<LearningNotificationModel> _notifications = [
    LearningNotificationModel(
      id: 'notification-001',
      title: 'Course review completed',
      message: 'The latest Flutter architecture course is ready to publish.',
      timeLabel: '2h ago',
      isRead: false,
    ),
    LearningNotificationModel(
      id: 'notification-002',
      title: 'Reminder',
      message: 'Three lessons are due for completion before Friday.',
      timeLabel: 'Yesterday',
      isRead: true,
    ),
    LearningNotificationModel(
      id: 'notification-003',
      title: 'Weekly live Q&A',
      message: 'Join the live Zoom session to review this week\'s roadmap.',
      timeLabel: 'Monday',
      isRead: false,
      zoomMeetingLink: 'https://zoom.us/j/1234567890',
    ),
  ];
}
