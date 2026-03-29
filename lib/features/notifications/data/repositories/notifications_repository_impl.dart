import 'package:e_learning/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:e_learning/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required NotificationsDataSource dataSource,
  }) : _dataSource = dataSource;

  final NotificationsDataSource _dataSource;

  @override
  Future<List<LearningNotification>> getNotifications() {
    return _dataSource.getNotifications();
  }

  @override
  Stream<List<LearningNotification>> watchNotifications() {
    return _dataSource.watchNotifications();
  }

  @override
  Future<LearningNotification> createNotification({
    required String title,
    required String message,
    required String zoomMeetingLink,
    String? targetCourseId,
  }) {
    return _dataSource.createNotification(
      title: title,
      message: message,
      zoomMeetingLink: zoomMeetingLink,
      targetCourseId: targetCourseId,
    );
  }
}
