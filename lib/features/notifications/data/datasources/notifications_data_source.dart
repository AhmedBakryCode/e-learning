import 'dart:async';
import 'dart:developer';

import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:e_learning/core/network/api_service.dart';
import 'package:e_learning/features/notifications/data/models/learning_notification_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

abstract class NotificationsDataSource {
  Future<List<LearningNotificationModel>> getNotifications();

  Stream<List<LearningNotificationModel>> watchNotifications();

  Future<LearningNotificationModel> createNotification({
    required String title,
    required String message,
    required String zoomMeetingLink,
    String? targetCourseId,
  });

  Future<void> markAsRead(String notificationId);
}

// ─────────────────────────────────────────────
// Remote data source – connects to real API
// + Socket.IO /notifications/stream
// ─────────────────────────────────────────────
class RemoteNotificationsDataSource implements NotificationsDataSource {
  RemoteNotificationsDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  // Socket.IO controller – lives for the lifetime of the data source
  io.Socket? _socket;
  final StreamController<List<LearningNotificationModel>> _streamController =
      StreamController<List<LearningNotificationModel>>.broadcast();

  // In-memory cache so the stream can re-emit on reconnect
  final List<LearningNotificationModel> _cached = [];

  @override
  Future<List<LearningNotificationModel>> getNotifications() async {
    final response = await _apiService.get(EndpointConstants.notifications);
    final List<dynamic> data = response.data;
    _cached
      ..clear()
      ..addAll(data.map((j) => LearningNotificationModel.fromJson(j)));
    return List<LearningNotificationModel>.from(_cached);
  }

  @override
  Stream<List<LearningNotificationModel>> watchNotifications() {
    _connectSocket();
    return _streamController.stream;
  }

  @override
  Future<LearningNotificationModel> createNotification({
    required String title,
    required String message,
    required String zoomMeetingLink,
    String? targetCourseId,
  }) async {
    final response = await _apiService.post(
      EndpointConstants.notifications,
      data: {
        'title': title,
        'message': message,
        'zoomMeetingLink': zoomMeetingLink,
        'targetCourseId': targetCourseId,
      },
    );
    return LearningNotificationModel.fromJson(response.data);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _apiService.patch('/notifications/$notificationId/read');
    // Optimistically update cache
    final idx = _cached.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _cached[idx] = _cached[idx].copyWith(isRead: true);
      _streamController.add(List<LearningNotificationModel>.from(_cached));
    }
  }

  void _connectSocket() {
    if (_socket != null && (_socket!.connected)) return;

    final socketUrl = EndpointConstants.baseUrl.replaceAll('/api/v1', '');
    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/notifications/stream')
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..on('connect', (_) {
        log('[Socket] Notifications stream connected');
        // Push current cached list immediately when connected
        if (_cached.isNotEmpty) {
          _streamController.add(List<LearningNotificationModel>.from(_cached));
        }
      })
      ..on('notification', (data) {
        try {
          final notification = LearningNotificationModel.fromJson(
            Map<String, dynamic>.from(data as Map),
          );
          _cached.insert(0, notification);
          _streamController.add(List<LearningNotificationModel>.from(_cached));
        } catch (e) {
          log('[Socket] Failed to parse notification: $e');
        }
      })
      ..on(
        'disconnect',
        (_) => log('[Socket] Notifications stream disconnected'),
      )
      ..on('error', (err) => log('[Socket] Notifications stream error: $err'))
      ..connect();
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _streamController.close();
  }
}

// ─────────────────────────────────────────────
// Mock data source – for testing / offline dev
// ─────────────────────────────────────────────
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
      audienceLabel: targetCourseId != null
          ? 'Course: $targetCourseId'
          : 'All students',
      zoomMeetingLink: zoomMeetingLink.isNotEmpty ? zoomMeetingLink : null,
      targetCourseId: targetCourseId,
    );

    _notifications.insert(0, notification);
    _controller.add(List<LearningNotificationModel>.from(_notifications));
    return notification;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future<void>.delayed(AppDurations.short);
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _controller.add(List<LearningNotificationModel>.from(_notifications));
    }
  }

  static final List<LearningNotificationModel> _notifications = [
    LearningNotificationModel(
      id: 'notification-001',
      title: 'Course review completed',
      message: 'The latest Flutter architecture course is ready to publish.',
      timeLabel: '2h ago',
      isRead: false,
      audienceLabel: 'All students',
    ),
    LearningNotificationModel(
      id: 'notification-002',
      title: 'Reminder',
      message: 'Three lessons are due for completion before Friday.',
      timeLabel: 'Yesterday',
      isRead: true,
      audienceLabel: 'All students',
    ),
    LearningNotificationModel(
      id: 'notification-003',
      title: 'Weekly live Q&A',
      message: 'Join the live Zoom session to review this week\'s roadmap.',
      timeLabel: 'Monday',
      isRead: false,
      audienceLabel: 'All students',
      zoomMeetingLink: 'https://zoom.us/j/1234567890',
    ),
  ];
}
