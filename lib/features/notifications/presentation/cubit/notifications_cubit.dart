import 'dart:async';

import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/notifications/domain/usecases/create_notification_usecase.dart';
import 'package:e_learning/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required GetNotificationsUseCase getNotifications,
    required WatchNotificationsUseCase watchNotifications,
    required CreateNotificationUseCase createNotification,
  }) : _getNotifications = getNotifications,
       _watchNotifications = watchNotifications,
       _createNotification = createNotification,
       super(const NotificationsState());

  final GetNotificationsUseCase _getNotifications;
  final WatchNotificationsUseCase _watchNotifications;
  final CreateNotificationUseCase _createNotification;
  StreamSubscription? _notificationsSubscription;

  Future<void> loadNotifications() async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    try {
      final notifications = await _getNotifications(const NoParams());
      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          notifications: notifications,
          isLive: true,
        ),
      );

      await _notificationsSubscription?.cancel();
      _notificationsSubscription = _watchNotifications().listen((items) {
        emit(
          state.copyWith(
            status: ViewStateStatus.success,
            notifications: items,
            isLive: true,
          ),
        );
      });
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          isLive: false,
          errorMessage: 'Unable to load notifications right now.',
        ),
      );
    }
  }

  Future<void> createNotification(CreateNotificationParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final notification = await _createNotification(params);
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: params.targetCourseId == null 
              ? 'Notification has been sent to all students.'
              : 'The notification has been sent to the students of the selected Course.',
          notifications: [notification, ...state.notifications],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to send this notification right now.',
        ),
      );
    }
  }

  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.initial,
        clearActionMessage: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _notificationsSubscription?.cancel();
    return super.close();
  }
}
