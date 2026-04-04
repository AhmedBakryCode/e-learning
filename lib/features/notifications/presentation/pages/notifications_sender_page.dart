import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/inline_feedback_card.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:e_learning/features/notifications/domain/usecases/create_notification_usecase.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationsSenderPage extends StatelessWidget {
  const NotificationsSenderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<NotificationsCubit>()..loadNotifications(),
        ),
        BlocProvider(
          create: (_) => sl<CoursesCubit>()..loadCourses(UserRole.admin),
        ),
      ],
      child: const _NotificationsSenderView(),
    );
  }
}

class _NotificationsSenderView extends StatefulWidget {
  const _NotificationsSenderView();

  @override
  State<_NotificationsSenderView> createState() =>
      _NotificationsSenderViewState();
}

class _NotificationsSenderViewState extends State<_NotificationsSenderView> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Live Zoom session reminder',
  );
  final TextEditingController _messageController = TextEditingController(
    text:
        'Join today\'s live session with the teacher to review the latest Course updates and ask questions.',
  );
  final TextEditingController _zoomLinkController = TextEditingController(
    text: 'https://zoom.us/j/1234567890',
  );
  String? _selectedCourseId;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _zoomLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus &&
          current.actionStatus != ViewStateStatus.initial,
      listener: (context, state) {
        final isLoading = state.actionStatus == ViewStateStatus.loading;
        final isSuccess = state.actionStatus == ViewStateStatus.success;
        final isFailure = state.actionStatus == ViewStateStatus.failure;

        if (isLoading) {
          // Show loading snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Sending notification...'),
                ],
              ),
              duration: Duration(seconds: 10),
            ),
          );
          return;
        }

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification sent successfully.')),
          );
          context.read<NotificationsCubit>().clearActionState();
          return;
        }

        if (isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ?? 'The notification could not be sent.',
              ),
            ),
          );
          context.read<NotificationsCubit>().clearActionState();
        }
      },
      builder: (context, state) {
        final isSending = state.actionStatus == ViewStateStatus.loading;
        final recentNotifications = state.notifications.take(5).toList();

        return AdaptiveScaffold(
          title: 'Notification Center',
          subtitle:
              'Send instant updates to all your students that appear directly on their devices.',
          selectedIndex: 3,
          onNavigationChanged: (index) => _onNavChanged(context, index),
          navigationDestinations: _getDestinations(),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: _buildForm(isSending),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: _buildLivePreviewAndHistory(recentNotifications),
                      ),
                    ),
                  ],
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
                  _buildForm(isSending),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildLivePreviewAndHistory(recentNotifications),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildForm(bool isSending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          title: 'Alert format',
          subtitle:
              'Enter the details of the alert that will be sent to students.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<CoursesCubit, CoursesState>(
                builder: (context, state) {
                  return DropdownButtonFormField<String>(
                    key: ValueKey(_selectedCourseId),
                    initialValue: _selectedCourseId,
                    isExpanded: true,
                    hint: const Text('Send to all students'),
                    decoration: InputDecoration(
                      labelText: 'Choose the target Course',
                      prefixIcon: const Icon(Icons.school_rounded),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All students'),
                      ),
                      ...state.courses.map(
                        (course) => DropdownMenuItem(
                          value: course.id,
                          child: Text(
                            course.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCourseId = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _messageController,
                label: 'Message',
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                controller: _zoomLinkController,
                label: 'Zoom link (optional)',
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const InlineFeedbackCard(
          title: 'Advice for sending',
          message:
              'Using shortened Zoom links increases student access to the session.',
          color: AppColors.secondary,
          icon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: isSending ? null : () => _send(context),
            icon: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              _selectedCourseId == null
                  ? 'Send now to everyone'
                  : 'Send to Course students',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLivePreviewAndHistory(List recentNotifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          title: 'Live preview',
          subtitle: 'How will the notification appear to the student?',
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedCourseId != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Specific to a specific Course',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  _titleController.text.isEmpty
                      ? 'Notice title'
                      : _titleController.text,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _messageController.text.isEmpty
                      ? 'Message content...'
                      : _messageController.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                if (_zoomLinkController.text.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _zoomLinkController.text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withAlpha(180),
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withAlpha(100),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        AppCard(
          title: 'Posting date',
          subtitle: 'Last 5 notifications sent.',
          child: recentNotifications.isEmpty
              ? const Text('There is no record currently.')
              : Column(
                  children: [
                    for (var i = 0; i < recentNotifications.length; i++) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          recentNotifications[i].title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${recentNotifications[i].audienceLabel}: ${recentNotifications[i].message}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.history_rounded, size: 16),
                      ),
                      if (i != recentNotifications.length - 1) const Divider(),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  void _onNavChanged(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/courses');
        break;
      case 2:
        context.go('/admin/students');
        break;
      case 3:
        context.go('/admin/notifications/send');
        break;
    }
  }

  List<NavigationDestination> _getDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        label: 'Courses',
      ),
      NavigationDestination(
        icon: Icon(Icons.groups_outlined),
        label: 'Students',
      ),
      NavigationDestination(icon: Icon(Icons.send_outlined), label: 'Send'),
    ];
  }

  void _send(BuildContext context) {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final zoomLink = _zoomLinkController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required fields.')),
      );
      return;
    }

    context.read<NotificationsCubit>().createNotification(
      CreateNotificationParams(
        title: title,
        message: message,
        zoomMeetingLink: zoomLink,
        targetCourseId: _selectedCourseId,
      ),
    );
  }
}
