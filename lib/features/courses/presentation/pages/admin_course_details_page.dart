import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/metric_highlight_card.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/skeleton_box.dart';
import 'package:e_learning/core/widgets/status_chip.dart';
import 'package:e_learning/core/widgets/responsive_layout.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:e_learning/features/courses/presentation/widgets/course_video_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminCourseDetailsPage extends StatelessWidget {
  const AdminCourseDetailsPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoursesCubit>()..loadCourseDetails(courseId),
      child: BlocConsumer<CoursesCubit, CoursesState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus &&
            current.actionStatus != ViewStateStatus.initial,
        listener: (context, state) {
          final isSuccess = state.actionStatus == ViewStateStatus.success;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ??
                    (isSuccess ? 'The action on the chorus was performed successfully.' : 'The action on the Course failed.'),
              ),
            ),
          );

          if (isSuccess && state.selectedCourse == null) {
            context.read<CoursesCubit>().clearActionState();
            context.go('/admin/courses');
            return;
          }

          context.read<CoursesCubit>().clearActionState();
        },
        builder: (context, state) {
          return AdaptiveScaffold(
            title: 'Course details',
            subtitle: 'Review the structure, lesson order, publishing status, and uploads.',
            selectedIndex: 1,
            onNavigationChanged: (index) => _onNavChanged(context, index),
            navigationDestinations: _getDestinations(),
            headerTrailing: state.status == ViewStateStatus.success && state.selectedCourse != null
                ? PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push('/admin/courses/$courseId/edit');
                      }
                      if (value == 'delete') {
                        final confirmed = await _confirmDelete(context);
                        if (confirmed && context.mounted) {
                          await context.read<CoursesCubit>().deleteCourse(courseId);
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit the chorus')),
                      PopupMenuDivider(),
                      PopupMenuItem(value: 'delete', child: Text('Delete the Course')),
                    ],
                    child: const Icon(Icons.more_vert_rounded),
                  )
                : null,
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: switch (state.status) {
                ViewStateStatus.loading => const _CourseDetailsLoading(),
                ViewStateStatus.failure => EmptyStateWidget(
                    title: 'The Course does not exist',
                    message: state.errorMessage ?? 'This Course may have been omitted from the experimental data.',
                    icon: Icons.menu_book_outlined,
                  ),
                _ => ResponsiveLayout(
                    mobile: _MobileLayout(courseId: courseId, state: state),
                    desktop: _DesktopLayout(courseId: courseId, state: state),
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
      case 0: context.go('/admin'); break;
      case 1: context.go('/admin/courses'); break;
      case 2: context.go('/admin/students'); break;
      case 3: context.go('/admin/notifications/send'); break;
    }
  }

  List<NavigationDestination> _getDestinations() {
    return const [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
      NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Students'),
      NavigationDestination(icon: Icon(Icons.send_outlined), label: 'Send'),
    ];
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete the Course?'),
          content: const Text('The Course and its list of demo lessons will be deleted from the control panel.'),
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

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.courseId, required this.state});
  final String courseId;
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
        _CourseMetrics(state: state),
        const SizedBox(height: AppSpacing.sectionGap),
        _NotesCard(state: state),
        const SizedBox(height: AppSpacing.sectionGap),
        _CourseHeaderCard(courseId: courseId, state: state),
        const SizedBox(height: AppSpacing.sectionGap),
        const SectionHeader(
          title: 'Educational content',
          subtitle: 'Each lesson clearly displays its data and upload status.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _VideosList(courseId: courseId, state: state),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.courseId, required this.state});
  final String courseId;
  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CourseMetrics(state: state, isVertical: false)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _NotesCard(state: state)),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            _CourseHeaderCard(courseId: courseId, state: state),
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(
              title: 'Educational content',
              subtitle: 'Each lesson clearly displays its data and upload status.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _VideosList(courseId: courseId, state: state),
          ],
        ),
      ),
    );
  }
}

class _CourseHeaderCard extends StatelessWidget {
  const _CourseHeaderCard({required this.courseId, required this.state});
  final String courseId;
  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    final course = state.selectedCourse!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primarySoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusChip(
                label: course.isPublished ? 'Published' : 'Draft',
                color: Colors.white,
                icon: course.isPublished ? Icons.check_circle_outline_rounded : Icons.edit_outlined,
              ),
              const StatusChip(
                label: 'Teacher control',
                color: Colors.white,
                icon: Icons.admin_panel_settings_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            course.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            course.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withAlpha(210),
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Main Instructor: ${course.instructorName}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push('/admin/courses/$courseId/edit'),
                  child: const Text('Edit the chorus'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/admin/courses/$courseId/videos/add'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withAlpha(60)),
                  ),
                  child: const Text('Add video'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseMetrics extends StatelessWidget {
  const _CourseMetrics({required this.state, this.isVertical = false});
  final CoursesState state;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    final course = state.selectedCourse!;
    final children = [
      Expanded(
        flex: isVertical ? 0 : 1,
        child: MetricHighlightCard(
          title: 'Lessons',
          value: '${course.totalLessons}',
          subtitle: 'Number of videos within the curriculum',
          icon: Icons.play_lesson_rounded,
          color: AppColors.secondary,
        ),
      ),
      if (isVertical) const SizedBox(height: AppSpacing.md) else const SizedBox(width: AppSpacing.lg),
      Expanded(
        flex: isVertical ? 0 : 1,
        child: MetricHighlightCard(
          title: 'Students',
          value: '${course.enrolledCount}',
          subtitle: 'Currently registered',
          icon: Icons.groups_rounded,
          color: AppColors.success,
        ),
      ),
    ];

    if (isVertical) {
      return Column(children: children);
    }
    return Row(children: children);
  }
}

class _VideosList extends StatelessWidget {
  const _VideosList({required this.courseId, required this.state});
  final String courseId;
  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    if (state.courseVideos.isEmpty) {
      return const EmptyStateWidget(
        title: 'There are no videos yet',
        message: 'Start adding the first video for this Course from the administration screen.',
        icon: Icons.video_library_outlined,
      );
    }
    return Column(
      children: state.courseVideos.map((video) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: CourseVideoTile(
            video: video,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'preview') {
                  context.go('/student/courses/$courseId/video/${video.id}');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'preview', child: Text('Preview as a student')),
              ],
              child: const Icon(Icons.more_horiz_rounded),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.state});
  final CoursesState state;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Publication notes',
      subtitle: 'A clear checklist before approving the Course.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ChecklistItem(title: 'Thumbnail and main text are approved', isDone: true),
          const _ChecklistItem(title: 'Lesson descriptions are consistent with the curriculum', isDone: true),
          _ChecklistItem(
            title: state.courseVideos.isEmpty ? 'Add the first video of the Course' : 'The lesson list has been filled out',
            isDone: state.courseVideos.isNotEmpty,
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.title, required this.isDone});
  final String title;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: isDone ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }
}

class _CourseDetailsLoading extends StatelessWidget {
  const _CourseDetailsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: const [
        SkeletonBox(height: 260, radius: AppRadii.xxl),
        SizedBox(height: AppSpacing.sectionGap),
        SkeletonBox(height: 148, radius: AppRadii.xl),
        SizedBox(height: AppSpacing.sectionGap),
        SkeletonBox(height: 156, radius: AppRadii.xl),
      ],
    );
  }
}
