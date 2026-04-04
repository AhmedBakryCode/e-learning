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
    required MarkNotificationReadUseCase markNotificationRead,
  }) : _getNotifications = getNotifications,
       _watchNotifications = watchNotifications,
       _createNotification = createNotification,
       _markNotificationRead = markNotificationRead,
       super(const NotificationsState());

  final GetNotificationsUseCase _getNotifications;
  final WatchNotificationsUseCase _watchNotifications;
  final CreateNotificationUseCase _createNotification;
  final MarkNotificationReadUseCase _markNotificationRead;
  StreamSubscription? _notificationsSubscription;

  /// Called on page open: shows loading spinner on first load,
  /// then keeps the stream alive silently in the background.
  Future<void> loadNotifications() async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    try {
      final notifications = await _getNotifications(const NoParams());
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          notifications: notifications,
          isLive: true,
        ),
      );

      // Start the live socket stream silently
      _startLiveStream();
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          isLive: false,
          errorMessage: 'Unable to load notifications right now.',
        ),
      );
    }
  }

  /// Starts the Socket.IO stream in the background.
  /// Never emits a loading state – updates land silently.
  void startLiveStreamSilently() {
    if (_notificationsSubscription != null) return;
    _startLiveStream();
  }

  void _startLiveStream() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _watchNotifications().listen((items) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          notifications: items,
          isLive: true,
        ),
      );
    });
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
      if (isClosed) return;
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
      if (isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to send this notification right now.',
        ),
      );
    }
  }

  /// Marks a notification as read via PATCH and updates state optimistically.
  Future<void> markAsRead(String notificationId) async {
    // Optimistic UI update
    final updated = state.notifications.map((n) {
      return n.id == notificationId ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(state.copyWith(notifications: updated));

    try {
      await _markNotificationRead(MarkNotificationReadParams(notificationId));
    } catch (_) {
      // Silently fail – the user already sees the read state
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
