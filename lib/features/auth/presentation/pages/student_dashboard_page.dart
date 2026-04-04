import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/home_components.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/skeleton_box.dart';
import 'package:e_learning/core/widgets/status_chip.dart';
import 'package:e_learning/core/widgets/responsive_grid.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_state.dart';
import 'package:e_learning/features/auth/presentation/cubit/student_dashboard_cubit.dart';
import 'package:e_learning/features/auth/presentation/cubit/student_dashboard_state.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/presentation/widgets/course_card.dart';
import 'package:e_learning/features/courses/presentation/widgets/course_featured_card.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final student = authState.user;

    if (student == null || authState.status != AuthStatus.authenticated) {
      return const AdaptiveScaffold(
        title: 'My Courses',
        subtitle: 'Preparing your learning space.',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<StudentDashboardCubit>()..loadDashboard(student.id),
        ),
        BlocProvider(
          create: (_) => sl<NotificationsCubit>()..loadNotifications(),
        ),
      ],
      child: BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
        builder: (context, state) {
          return AdaptiveScaffold(
            title: 'My Courses',
            subtitle:
                'Track your progress, complete the appropriate lesson, and keep going.',
            selectedIndex: 0,
            onNavigationChanged: (index) => _onNavChanged(context, index),
            leading: BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, notificationsState) {
                final unreadCount = notificationsState.notifications
                    .where((n) => !n.isRead)
                    .length;
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: IconButton.filledTonal(
                    onPressed: () => context.push('/student/notifications'),
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                );
              },
            ),
            navigationDestinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'My Courses',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded),
                label: 'Progressive',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
            actions: [
              IconButton.filledTonal(
                onPressed: () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: switch (state.status) {
                ViewStateStatus.loading => const _StudentDashboardLoading(),
                ViewStateStatus.failure => EmptyStateWidget(
                  title: 'Unable to download Courses',
                  message: state.errorMessage ?? 'Try again shortly.',
                  icon: Icons.school_outlined,
                  action: FilledButton(
                    onPressed: () => context
                        .read<StudentDashboardCubit>()
                        .loadDashboard(student.id),
                    child: const Text('Retry'),
                  ),
                ),
                _ => _StudentDashboardContent(
                  studentName: student.name,
                  state: state,
                ),
              },
            ),
          );
        },
      ),
    );
  }

  void _onNavChanged(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/student');
        break;
      case 1:
        context.go('/student/courses');
        break;
      case 2:
        context.go('/student/progress');
        break;
      case 3:
        context.go('/student/settings');
        break;
    }
  }
}

class _StudentDashboardContent extends StatelessWidget {
  const _StudentDashboardContent({
    required this.studentName,
    required this.state,
  });

  final String studentName;
  final StudentDashboardState state;

  @override
  Widget build(BuildContext context) {
    final continueCourse = state.continueCourse;
    final continueProgress = state.continueProgress;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.huge,
      ),
      children: [
        // Notifications Section
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, notificationsState) {
            if (notificationsState.status == ViewStateStatus.loading ||
                notificationsState.notifications.isEmpty) {
              return const SizedBox.shrink();
            }
            final recentNotifications = notificationsState.notifications
                .take(3)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: const SectionHeader(
                        title: 'Recent Notifications',
                        subtitle: 'Latest updates from your instructors.',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/student/notifications'),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...recentNotifications.map(
                  (notification) => Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      leading: Icon(
                        notification.isRead
                            ? Icons.notifications_outlined
                            : Icons.notifications_active_rounded,
                        color: notification.isRead ? null : AppColors.secondary,
                      ),
                      title: Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        notification.timeLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => context.push('/student/notifications'),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
              ],
            );
          },
        ),
        if (continueCourse != null && continueProgress != null)
          _ContinueLearningCard(
            learnerName: studentName,
            courseTitle: continueCourse.title,
            progressLabel:
                '${(continueProgress.completionPercent * 100).round()}% complete',
            lessonLabel:
                continueProgress.lastVideoTitle ?? 'Complete the next lesson',
            onResume: () =>
                context.push('/student/courses/${continueCourse.id}'),
          )
        else
          const EmptyStateWidget(
            title: 'There is no active Course currently',
            message:
                'Your registered Courses will appear here once you start your learning journey.',
            icon: Icons.play_circle_outline_rounded,
          ),
        const SizedBox(height: AppSpacing.sectionGap),
        const HomeShowcasePageView(),
        const SizedBox(height: AppSpacing.sectionGap),
        const SectionHeader(
          title: 'My Courses',
          subtitle: 'All registered Courses with current progress rate.',
        ),
        const SizedBox(height: AppSpacing.lg),
        if (state.enrolledCourses.isEmpty)
          const EmptyStateWidget(
            title: 'There are no registered Courses',
            message:
                'Once you register for any Course from the teacher, it will appear here.',
            icon: Icons.menu_book_outlined,
          )
        else
          ResponsiveGrid(
            mobileCrossAxisCount: 1,
            tabletCrossAxisCount: 2,
            desktopCrossAxisCount: 3,
            children: state.enrolledCourses.map((course) {
              return CourseCard(
                course: course,
                role: UserRole.student,
                onTap: () => context.push('/student/courses/${course.id}'),
              );
            }).toList(),
          ),
        if (state.enrolledCourses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          SectionHeader(
            title: 'Complete the learning',
            subtitle: 'Quick cards to complete based on your actual progress.',
            action: TextButton(
              onPressed: () => context.push('/student/courses'),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 350,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.enrolledCourses.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.lg),
              itemBuilder: (context, index) {
                final course = state.enrolledCourses[index];
                return SizedBox(
                  width: 300,
                  child: CourseFeaturedCard(
                    course: course,
                    onTap: () => context.push('/student/courses/${course.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.learnerName,
    required this.courseTitle,
    required this.progressLabel,
    required this.lessonLabel,
    required this.onResume,
  });

  final String learnerName;
  final String courseTitle;
  final String progressLabel;
  final String lessonLabel;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: Theme.of(context).brightness == Brightness.dark
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              'Welcome back, $learnerName',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            courseTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            lessonLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white.withAlpha(200)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Complete'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              StatusChip(
                label: progressLabel,
                color: Colors.white,
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentDashboardLoading extends StatelessWidget {
  const _StudentDashboardLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: const [
        SkeletonBox(height: 220, radius: AppRadii.xxl),
        SizedBox(height: AppSpacing.sectionGap),
        SkeletonBox(height: 170, radius: AppRadii.xl),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 170, radius: AppRadii.xl),
      ],
    );
  }
}
