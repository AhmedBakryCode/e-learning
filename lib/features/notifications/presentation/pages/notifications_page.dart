import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/skeleton_box.dart';
import 'package:e_learning/core/widgets/status_chip.dart';
import 'package:e_learning/core/widgets/responsive_grid.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..loadNotifications(),
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return AdaptiveScaffold(
            title: 'Alert notifications',
            subtitle: 'Organized alerts with clear reading statuses.',
            selectedIndex: 0,
            navigationDestinations: const [],
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: switch (state.status) {
                ViewStateStatus.loading => const _NotificationsLoading(),
                ViewStateStatus.failure => EmptyStateWidget(
                  title: 'Unable to load notifications',
                  message: state.errorMessage ?? 'Try again shortly.',
                  icon: Icons.notifications_off_rounded,
                ),
                _ => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    0,
                    AppSpacing.pagePadding,
                    AppSpacing.huge,
                  ),
                  children: [
                    AppCard(
                      child: Row(
                        children: [
                          const Icon(Icons.podcasts_rounded),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              state.isLive
                                  ? 'Live updates are online'
                                  : 'Waiting for live updates',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          StatusChip(
                            label: state.isLive ? 'Live' : 'Offline',
                            color: state.isLive
                                ? AppColors.success
                                : AppColors.warning,
                            icon: state.isLive
                                ? Icons.bolt_rounded
                                : Icons.pause_circle_outline_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    if (state.notifications.isEmpty)
                      const EmptyStateWidget(
                        title: 'No notifications yet',
                        message:
                            'Notifications from your teacher\'s dashboard will appear here.',
                        icon: Icons.notifications_none_rounded,
                      )
                    else
                      ResponsiveGrid(
                        mobileCrossAxisCount: 2,
                        tabletCrossAxisCount: 2,
                        desktopCrossAxisCount: 2,
                        children: state.notifications.map((notification) {
                          return InkWell(
                            onTap: role == UserRole.student
                                ? () => _openNotificationDetails(
                                    context,
                                    notification,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            child: AppCard(
                              title: notification.title,
                              subtitle: notification.timeLabel,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  if (notification.zoomMeetingLink != null &&
                                      MediaQuery.of(context).size.width >=
                                          400) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      notification.zoomMeetingLink!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.secondary,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.md),
                                  Wrap(
                                    spacing: AppSpacing.xs,
                                    runSpacing: AppSpacing.xs,
                                    children: [
                                      StatusChip(
                                        label: notification.isRead
                                            ? 'Readable'
                                            : 'Illegible',
                                        color: notification.isRead
                                            ? AppColors.success
                                            : AppColors.secondary,
                                        icon: notification.isRead
                                            ? Icons.done_all_rounded
                                            : Icons.mark_chat_unread_rounded,
                                      ),
                                      StatusChip(
                                        label: notification.audienceLabel,
                                        color: AppColors.primary,
                                        icon: Icons.groups_rounded,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              },
            ),
          );
        },
      ),
    );
  }

  void _openNotificationDetails(
    BuildContext context,
    LearningNotification notification,
  ) {
    context.push(
      '/student/notifications/${notification.id}',
      extra: notification,
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
      children: List.generate(
        3,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: SkeletonBox(height: 138, radius: AppRadii.xl),
        ),
      ),
    );
  }
}
