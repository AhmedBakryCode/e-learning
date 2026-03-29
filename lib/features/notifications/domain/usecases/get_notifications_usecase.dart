import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:e_learning/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase
    implements UseCase<List<LearningNotification>, NoParams> {
  const GetNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<List<LearningNotification>> call(NoParams params) {
    return _repository.getNotifications();
  }
}

class WatchNotificationsUseCase {
  const WatchNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Stream<List<LearningNotification>> call() {
    return _repository.watchNotifications();
  }
}
