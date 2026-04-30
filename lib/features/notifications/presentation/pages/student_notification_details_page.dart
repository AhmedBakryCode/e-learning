import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentNotificationDetailsPage extends StatefulWidget {
  const StudentNotificationDetailsPage({super.key, required this.notification});

  final LearningNotification notification;

  @override
  State<StudentNotificationDetailsPage> createState() =>
      _StudentNotificationDetailsPageState();
}

class _StudentNotificationDetailsPageState
    extends State<StudentNotificationDetailsPage> {
  late LearningNotification _notification;


  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
    _markAsRead();
  }



  void _markAsRead() {
    if (!_notification.isRead) {
      context.read<NotificationsCubit>().markAsRead(_notification.id);
      setState(() {
        _notification = _notification.copyWith(isRead: true);
      });
    }
  }

  Future<void> _launchMeeting() async {
    String? link = _notification.zoomMeetingLink?.trim();
    if (link == null || link.isEmpty) return;

    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      link = 'https://$link';
    }

    final uri = Uri.parse(link);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open meeting link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Notification Details',
      subtitle: 'View full message and join meeting',
      selectedIndex: 0,
      navigationDestinations: const [],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          0,
          AppSpacing.pagePadding,
          AppSpacing.huge,
        ),
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Header Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            _notification.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _notification.timeLabel,
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
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: _notification.isRead
                        ? AppColors.success.withAlpha(20)
                        : AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _notification.isRead
                            ? Icons.check_circle_rounded
                            : Icons.mark_email_unread_rounded,
                        size: 16,
                        color: _notification.isRead
                            ? AppColors.success
                            : AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _notification.isRead ? 'Read' : 'Unread',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _notification.isRead
                              ? AppColors.success
                              : AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Message Card
          AppCard(
            title: 'Message',
            child: Text(
              _notification.message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Audience info
          AppCard(
            title: 'Audience',
            child: Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _notification.audienceLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Meeting Button
          if (_notification.zoomMeetingLink != null &&
              _notification.zoomMeetingLink!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _launchMeeting,
                icon: const Icon(Icons.video_call_rounded),
                label: const Text('Join Meeting'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.muted.withAlpha(100),
                  disabledForegroundColor: Colors.white.withAlpha(150),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          // Back button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Notifications'),
            ),
          ),
        ],
      ),
    );
  }
}
