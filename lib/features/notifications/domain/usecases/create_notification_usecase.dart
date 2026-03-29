import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:e_learning/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:equatable/equatable.dart';

class CreateNotificationParams extends Equatable {
  const CreateNotificationParams({
    required this.title,
    required this.message,
    required this.zoomMeetingLink,
    this.targetCourseId,
  });

  final String title;
  final String message;
  final String zoomMeetingLink;
  final String? targetCourseId;

  @override
  List<Object?> get props => [title, message, zoomMeetingLink, targetCourseId];
}

class CreateNotificationUseCase
    implements UseCase<LearningNotification, CreateNotificationParams> {
  const CreateNotificationUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<LearningNotification> call(CreateNotificationParams params) {
    return _repository.createNotification(
      title: params.title,
      message: params.message,
      zoomMeetingLink: params.zoomMeetingLink,
      targetCourseId: params.targetCourseId,
    );
  }
}
