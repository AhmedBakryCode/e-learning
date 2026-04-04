import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentNotificationsStreamPage extends StatelessWidget {
  const StudentNotificationsStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..loadNotifications(),
      child: const _StudentNotificationsView(),
    );
  }
}

class _StudentNotificationsView extends StatefulWidget {
  const _StudentNotificationsView();

  @override
  State<_StudentNotificationsView> createState() =>
      _StudentNotificationsViewState();
}

class _StudentNotificationsViewState extends State<_StudentNotificationsView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus &&
          current.actionStatus != ViewStateStatus.initial,
      listener: (context, state) {
        if (state.actionMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionMessage!)));
        }
        context.read<NotificationsCubit>().clearActionState();
      },
      builder: (context, state) {
        return AdaptiveScaffold(
          title: 'Notifications',
          subtitle: 'Real-time updates and announcements',
          selectedIndex: 0,
          navigationDestinations: const [],
          body: AnimatedSwitcher(
            duration: AppDurations.medium,
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NotificationsState state) {
    // Always show notifications list, even when loading initially
    // Stream updates come silently without loading state
    if (state.status == ViewStateStatus.loading &&
        state.notifications.isEmpty) {
      return const _NotificationsLoading();
    }

    if (state.status == ViewStateStatus.failure &&
        state.notifications.isEmpty) {
      return EmptyStateWidget(
        title: 'Unable to load notifications',
        message: state.errorMessage ?? 'Try again shortly.',
        icon: Icons.notifications_off_rounded,
        action: FilledButton(
          onPressed: () =>
              context.read<NotificationsCubit>().loadNotifications(),
          child: const Text('Retry'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.huge,
      ),
      children: [
        // Live status indicator
        AppCard(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.isLive ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  state.isLive
                      ? 'Live stream connected - receiving real-time updates'
                      : 'Connecting to notification stream...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (state.isLive)
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (state.notifications.isEmpty)
          const EmptyStateWidget(
            title: 'No notifications yet',
            message:
                'You will receive notifications here when your teacher sends updates.',
            icon: Icons.notifications_none_rounded,
          )
        else
          ...state.notifications.map(
            (notification) => _NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(context, notification),
            ),
          ),
      ],
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    LearningNotification notification,
  ) {
    // Mark as read when opened
    if (!notification.isRead) {
      context.read<NotificationsCubit>().markAsRead(notification.id);
    }

    // Show notification detail with Zoom button if available
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (sheetContext) => _NotificationDetailSheet(
        notification: notification,
        onJoinMeeting: notification.zoomMeetingLink != null
            ? () => _launchZoomMeeting(notification.zoomMeetingLink!)
            : null,
      ),
    );
  }

  Future<void> _launchZoomMeeting(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open meeting link')),
        );
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final LearningNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Unread indicator
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary,
                      ),
                    ),
                  if (!notification.isRead)
                    const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    notification.timeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (notification.zoomMeetingLink != null) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      Icons.video_call_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Zoom meeting available',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    notification.audienceLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({
    required this.notification,
    required this.onJoinMeeting,
  });

  final LearningNotification notification;
  final VoidCallback? onJoinMeeting;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        notification.timeLabel,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Message
            Text(
              notification.message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Audience info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    notification.audienceLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Zoom join button
            if (onJoinMeeting != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onJoinMeeting,
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Join Zoom Meeting'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _NotificationsLoading extends StatelessWidget {
  const _NotificationsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.huge,
      ),
      children: [
        // Live status placeholder
        Container(
          height: 60,
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
        // Notification skeletons
        for (int i = 0; i < 3; i++)
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
          ),
      ],
    );
  }
}
