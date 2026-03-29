import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';

abstract class NotificationsRepository {
  Future<List<LearningNotification>> getNotifications();

  Stream<List<LearningNotification>> watchNotifications();

  Future<LearningNotification> createNotification({
    required String title,
    required String message,
    required String zoomMeetingLink,
    String? targetCourseId,
  });
}
