import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/custom_text_field.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/inline_feedback_card.dart';
import 'package:e_learning/core/widgets/metric_highlight_card.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/skeleton_box.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:e_learning/features/courses/presentation/widgets/course_card.dart';
import 'package:e_learning/features/courses/presentation/widgets/course_featured_card.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_state.dart';
import 'package:e_learning/core/widgets/responsive_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CoursesCubit>()..loadCourses(role)),
        if (role == UserRole.student)
          BlocProvider(
            create: (context) {
              final user = context.read<AuthCubit>().state.user;
              return sl<ProgressCubit>()..loadProgress(studentId: user?.id);
            },
          ),
      ],
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          final destinations = _getNavigationDestinations(role);

          return AdaptiveScaffold(
            title: role == UserRole.admin ? 'Course management' : 'Course library',
            subtitle: role == UserRole.admin
                ? 'Manage content quality, drafts, videos, and publishing status.'
                : 'Browse educational paths with clear progress indicators.',
            selectedIndex: 1,
            onNavigationChanged: (index) => _onNavChanged(context, role, index),
            navigationDestinations: destinations,
            body: state.status == ViewStateStatus.loading
                ? _CoursesLoading(role: role)
                : state.status == ViewStateStatus.failure
                    ? _CoursesError(
                        role: role,
                        onRetry: () =>
                            context.read<CoursesCubit>().loadCourses(role),
                      )
                    : _CoursesLoaded(role: role, state: state),
          );
        },
      ),
    );
  }

  void _onNavChanged(BuildContext context, UserRole role, int index) {
    if (role == UserRole.admin) {
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
      return;
    }

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
    }
  }

  List<NavigationDestination> _getNavigationDestinations(UserRole role) {
    if (role == UserRole.admin) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups_rounded),
          label: 'Students',
        ),
        NavigationDestination(
          icon: Icon(Icons.send_outlined),
          selectedIcon: Icon(Icons.send_rounded),
          label: 'Send',
        ),
      ];
    }

    return const [
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
    ];
  }
}

class _CoursesLoaded extends StatelessWidget {
  const _CoursesLoaded({required this.role, required this.state});

  final UserRole role;
  final CoursesState state;

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
        if (role == UserRole.admin) ...[
          const InlineFeedbackCard(
            title: 'The permissions system has been updated',
            message:
                'You can now drag Courses to rearrange them or tap and hold to quickly change their publishing status.',
            color: AppColors.secondary,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Row(
            children: const [
              Expanded(
                child: MetricHighlightCard(
                  title: 'Active Courses',
                  value: '24',
                  subtitle: '+3 this month',
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: MetricHighlightCard(
                  title: 'Total students',
                  value: '1.2k',
                  subtitle: '+12%',
                  icon: Icons.moving_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
        const CustomTextField(
          prefixIcon: Icon(Icons.search_rounded),
          hintText: 'Search for a Course, teacher, or category...',
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        const SectionHeader(
          title: 'Distinctive Courses',
          subtitle: 'The best rated and most popular content among students.',
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 400,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.featuredCourses.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              final course = state.featuredCourses[index];
              return SizedBox(
                width: 310,
                child: CourseFeaturedCard(
                  course: course,
                  onTap: () => _openCourse(context, role, course.id),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        if (role == UserRole.admin) ...[
          const SectionHeader(
            title: 'Control menu',
            subtitle: 'Click the arrow for quick access to edit or review options.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _AdminCoursesList(state: state),
        ] else
          BlocBuilder<ProgressCubit, ProgressState>(
            builder: (context, progressState) {
              final enrolledCourseIds = progressState.progressItems.map((p) => p.courseId).toSet();

              final myCourses = state.filteredCourses
                  .where((course) => enrolledCourseIds.contains(course.id))
                  .toList();

              final otherCourses = state.filteredCourses
                  .where((course) => !enrolledCourseIds.contains(course.id))
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (myCourses.isNotEmpty) ...[
                    const SectionHeader(
                      title: 'My current Courses',
                      subtitle: 'Track your progress in these recorded Courses.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ResponsiveGrid(
                      mobileCrossAxisCount: 1,
                      tabletCrossAxisCount: 2,
                      desktopCrossAxisCount: 3,
                      children: myCourses.map((course) => CourseCard(
                        course: course,
                        role: role,
                        onTap: () => _openCourse(context, role, course.id),
                      )).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],

                  const SectionHeader(
                    title: 'Other Courses available',
                    subtitle: 'Explore and enroll in new Courses to develop your skills.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (otherCourses.isEmpty)
                    const EmptyStateWidget(
                      title: 'There are no other Courses currently available',
                      message: 'It seems that you are subscribed to all currently available Courses! Waiting for new content soon.',
                      icon: Icons.check_circle_outline_rounded,
                    )
                  else
                    ResponsiveGrid(
                      mobileCrossAxisCount: 1,
                      tabletCrossAxisCount: 2,
                      desktopCrossAxisCount: 3,
                      children: otherCourses.map((course) => CourseCard(
                        course: course,
                        role: role,
                        actionLabel: 'Explore the Course',
                        onTap: () => _openCourse(context, role, course.id),
                      )).toList(),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  void _openCourse(BuildContext context, UserRole role, String courseId) {
    context.push(role == UserRole.admin ? '/admin/courses/$courseId' : '/student/courses/$courseId');
  }
}

class _AdminCoursesList extends StatelessWidget {
  const _AdminCoursesList({required this.state});
  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    if (state.filteredCourses.isEmpty) {
      return const EmptyStateWidget(
        title: 'There are no matching Courses',
        message: 'Try a different filter or add a new Course to expand this list.',
        icon: Icons.filter_alt_off_rounded,
      );
    }

    return ResponsiveGrid(
      mobileCrossAxisCount: 1,
      tabletCrossAxisCount: 2,
      desktopCrossAxisCount: 3,
      children: state.filteredCourses.map((course) {
        return Stack(
          children: [
            CourseCard(
              course: course,
              role: UserRole.admin,
              actionLabel: 'Course management',
              onTap: () => _openCourse(context, UserRole.admin, course.id),
            ),
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    context.push('/admin/courses/${course.id}/edit');
                  }
                  if (value == 'video') {
                    context.push('/admin/courses/${course.id}/videos/add');
                  }
                  if (value == 'delete') {
                    final confirmed = await _confirmDeleteCourse(
                      context,
                      course.title,
                    );
                    if (confirmed && context.mounted) {
                      await context.read<CoursesCubit>().deleteCourse(course.id);
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit the chorus')),
                  PopupMenuItem(value: 'video', child: Text('Add video')),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'delete', child: Text('Delete the Course')),
                ],
                child: const Icon(Icons.more_horiz_rounded),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _openCourse(BuildContext context, UserRole role, String courseId) {
    context.push(role == UserRole.admin ? '/admin/courses/$courseId' : '/student/courses/$courseId');
  }

  Future<bool> _confirmDeleteCourse(BuildContext context, String title) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete the Course'),
          content: Text(
            'Are you sure to delete "$title"? This step cannot be undone and all data related to it will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

class _CoursesLoading extends StatelessWidget {
  const _CoursesLoading({required this.role});

  final UserRole role;

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
        const SkeletonBox(height: 116, radius: AppRadii.xxl),
        const SizedBox(height: AppSpacing.sectionGap),
        Row(
          children: const [
            Expanded(child: SkeletonBox(height: 148, radius: AppRadii.xl)),
            SizedBox(width: AppSpacing.lg),
            Expanded(child: SkeletonBox(height: 148, radius: AppRadii.xl)),
          ],
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        const SkeletonBox(height: 58, radius: AppRadii.xl),
        const SizedBox(height: AppSpacing.md),
        const SkeletonBox(height: 38, width: 230, radius: AppRadii.pill),
        const SizedBox(height: AppSpacing.sectionGap),
        ...List.generate(
          role == UserRole.admin ? 4 : 3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: SkeletonBox(height: 236, radius: AppRadii.xl),
          ),
        ),
      ],
    );
  }
}

class _CoursesError extends StatelessWidget {
  const _CoursesError({required this.role, required this.onRetry});

  final UserRole role;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Unable to retrieve Course list',
      message: 'Check your internet connection and try again.',
      icon: Icons.error_outline_rounded,
      action: FilledButton(onPressed: onRetry, child: const Text('Retry')),
    );
  }
}
