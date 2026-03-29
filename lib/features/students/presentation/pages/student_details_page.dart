import 'dart:io';

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
import 'package:e_learning/core/widgets/responsive_layout.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/usecases/enroll_in_course_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/update_progress_usecase.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_state.dart';
import 'package:e_learning/features/students/presentation/cubit/students_cubit.dart';
import 'package:e_learning/features/students/presentation/cubit/students_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StudentDetailsPage extends StatelessWidget {
  const StudentDetailsPage({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<StudentsCubit>()..loadStudentDetails(studentId)),
        BlocProvider(create: (_) => sl<ProgressCubit>()..loadProgress(studentId: studentId)),
        BlocProvider(create: (_) => sl<CoursesCubit>()..loadCourses(UserRole.admin)),
      ],
      child: _StudentDetailsView(studentId: studentId),
    );
  }
}

class _StudentDetailsView extends StatelessWidget {
  const _StudentDetailsView({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StudentsCubit, StudentsState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus &&
              current.actionStatus != ViewStateStatus.initial,
          listener: (context, state) {
            final isSuccess = state.actionStatus == ViewStateStatus.success;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.actionMessage ?? (isSuccess ? 'The procedure was performed on the student successfully.' : 'The action failed on the student.'),
                ),
              ),
            );

            if (isSuccess && state.selectedStudent == null) {
              context.read<StudentsCubit>().clearActionState();
              context.go('/admin/students');
              return;
            }

            context.read<StudentsCubit>().clearActionState();
          },
        ),
        BlocListener<ProgressCubit, ProgressState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus &&
              current.actionStatus != ViewStateStatus.initial,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.actionMessage ?? (state.actionStatus == ViewStateStatus.success ? 'Progress updated.' : 'Unable to update progress.'),
                ),
              ),
            );

            if (state.actionStatus == ViewStateStatus.success) {
              context.read<StudentsCubit>().loadStudentDetails(studentId);
            }

            context.read<ProgressCubit>().clearActionState();
          },
        ),
      ],
      child: BlocBuilder<StudentsCubit, StudentsState>(
        builder: (context, studentState) {
          final progressState = context.watch<ProgressCubit>().state;

          return AdaptiveScaffold(
            title: 'Student details',
            subtitle: 'Review student status, enrolled Courses, and manual progress updates.',
            selectedIndex: 2,
            onNavigationChanged: (index) => _onNavChanged(context, index),
            navigationDestinations: _getDestinations(),
            headerTrailing: studentState.status == ViewStateStatus.success && studentState.selectedStudent != null
                ? PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push('/admin/students/$studentId/edit');
                      }
                      if (value == 'delete') {
                        final confirmed = await _confirmDelete(context);
                        if (confirmed && context.mounted) {
                          await context.read<StudentsCubit>().deleteStudent(studentId);
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit Student')),
                      PopupMenuDivider(),
                      PopupMenuItem(value: 'delete', child: Text('Delete student')),
                    ],
                    child: const Icon(Icons.more_vert_rounded),
                  )
                : null,
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: switch (studentState.status) {
                ViewStateStatus.loading => const _StudentDetailsLoading(),
                ViewStateStatus.failure => EmptyStateWidget(
                    title: 'The student is not present',
                    message: studentState.errorMessage ?? 'This student does not exist within the current experimental data.',
                    icon: Icons.person_search_rounded,
                  ),
                _ => ResponsiveLayout(
                    mobile: _MobileLayout(
                      studentId: studentId,
                      studentState: studentState, 
                      progressState: progressState,
                    ),
                    desktop: _DesktopLayout(
                      studentId: studentId,
                      studentState: studentState, 
                      progressState: progressState,
                    ),
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
          title: const Text('Delete student?'),
          content: const Text('The student will be deleted from the experimental control panel.'),
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
  const _MobileLayout({
    required this.studentId,
    required this.studentState, 
    required this.progressState,
  });
  final String studentId;
  final StudentsState studentState;
  final ProgressState progressState;

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
        _UserInfoCard(studentState: studentState),
        const SizedBox(height: AppSpacing.sectionGap),
        _UserMetricsRow(studentState: studentState),
        const SizedBox(height: AppSpacing.sectionGap),
        const SizedBox(height: AppSpacing.sm),
        _ProgressHeader(studentId: studentId, progressState: progressState),
        const SizedBox(height: AppSpacing.lg),
        _ProgressList(progressState: progressState),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.studentId,
    required this.studentState, 
    required this.progressState,
  });
  final String studentId;
  final StudentsState studentState;
  final ProgressState progressState;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            children: [
              _UserInfoCard(studentState: studentState),
              const SizedBox(height: AppSpacing.sectionGap),
              _ProgressHeader(studentId: studentId, progressState: progressState),
              const SizedBox(height: AppSpacing.lg),
              _ProgressList(progressState: progressState),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: _UserMetricsRow(studentState: studentState, isVertical: true),
          ),
        ),
      ],
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.studentState});
  final StudentsState studentState;

  @override
  Widget build(BuildContext context) {
    final student = studentState.selectedStudent!;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: student.profileImagePath == null
                  ? const LinearGradient(colors: [AppColors.primary, AppColors.primarySoft])
                  : null,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              child: student.profileImagePath != null
                  ? (kIsWeb
                      ? Image.network(
                          student.profileImagePath!,
                          fit: BoxFit.cover,
                          width: 72,
                          height: 72,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person),
                        )
                      : Image.file(
                          File(student.profileImagePath!),
                          fit: BoxFit.cover,
                          width: 72,
                          height: 72,
                        ))
                  : Center(
                      child: Text(
                        student.name.split(' ').map((part) => part[0]).take(2).join(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(student.email),
                const SizedBox(height: AppSpacing.sm),
                const Text('Educational group - managed by the teacher'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMetricsRow extends StatelessWidget {
  const _UserMetricsRow({required this.studentState, this.isVertical = false});
  final StudentsState studentState;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    final student = studentState.selectedStudent!;

    final children = [
      Expanded(
        flex: isVertical ? 0 : 1,
        child: MetricHighlightCard(
          title: 'Completion',
          value: '${(student.completionRate * 100).round()}%',
          subtitle: 'Across all Courses',
          icon: Icons.show_chart_rounded,
          color: AppColors.success,
        ),
      ),
      if (isVertical) const SizedBox(height: AppSpacing.md) else const SizedBox(width: AppSpacing.lg),
      Expanded(
        flex: isVertical ? 0 : 1,
        child: MetricHighlightCard(
          title: 'Courses',
          value: '${student.activeCourses}',
          subtitle: 'Currently under study',
          icon: Icons.menu_book_rounded,
          color: AppColors.secondary,
        ),
      ),
    ];

    if (isVertical) {
      return Column(children: children);
    }
    return Row(children: children);
  }
}

class _ProgressList extends StatelessWidget {
  const _ProgressList({required this.progressState});
  final ProgressState progressState;

  @override
  Widget build(BuildContext context) {
    if (progressState.status == ViewStateStatus.loading) {
      return const SkeletonBox(height: 180, radius: AppRadii.xl);
    } else if (progressState.progressItems.isEmpty) {
      return const EmptyStateWidget(
        title: 'There are no registered Courses',
        message: 'There are no progress records for this student currently within the demo data.',
        icon: Icons.school_outlined,
      );
    } else {
      return Column(
        children: progressState.progressItems.map((progress) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: AppCard(
              title: progress.courseTitle,
              subtitle: 'Lesson ${progress.currentLesson} from ${progress.totalLessons}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: progress.completionPercent,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('${(progress.completionPercent * 100).round()}% completed'),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _showProgressEditor(context, progress),
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Update progress'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Future<void> _showProgressEditor(BuildContext context, LearningProgress progress) async {
    final progressCubit = context.read<ProgressCubit>();
    var percent = progress.completionPercent;
    var currentLesson = progress.currentLesson.toDouble();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: progressCubit,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.pagePadding,
                  AppSpacing.pagePadding,
                  MediaQuery.of(context).viewInsets.bottom + AppSpacing.pagePadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${progress.courseTitle} update',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('${(percent * 100).round()}% completion', style: Theme.of(context).textTheme.titleMedium),
                    Slider(
                      value: percent,
                      onChanged: (value) => setSheetState(() => percent = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Current lesson ${currentLesson.round()} from ${progress.totalLessons}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Slider(
                      value: currentLesson,
                      min: 0,
                      max: progress.totalLessons.toDouble(),
                      divisions: progress.totalLessons,
                      onChanged: (value) => setSheetState(() => currentLesson = value),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              context.read<ProgressCubit>().updateProgress(
                                UpdateProgressParams(
                                  progressId: progress.id,
                                  completionPercent: percent,
                                  currentLesson: currentLesson.round(),
                                ),
                              );
                              Navigator.of(sheetContext).pop();
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.studentId, required this.progressState});
  final String studentId;
  final ProgressState progressState;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: SectionHeader(
            title: 'Registered Courses',
            subtitle: 'Manual progress updating is available for each Course in which a student is registered.',
          ),
        ),
        FilledButton.icon(
          onPressed: () => _showAddCourseDialog(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add a Course'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
        ),
      ],
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final coursesCubit = context.read<CoursesCubit>();
    final progressCubit = context.read<ProgressCubit>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: coursesCubit),
            BlocProvider.value(value: progressCubit),
          ],
          child: BlocBuilder<CoursesCubit, CoursesState>(
            builder: (context, coursesState) {
              final enrolledCourseIds = progressState.progressItems.map((p) => p.courseId).toSet();
              final availableCourses = coursesState.courses.where(
                (course) => !enrolledCourseIds.contains(course.id)
              ).toList();

              return AlertDialog(
                title: const Text('Add a Course for the student'),
                content: SizedBox(
                  width: 400,
                  child: coursesState.status == ViewStateStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : availableCourses.isEmpty
                          ? const Text('Registered for all available Courses.')
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: availableCourses.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final course = availableCourses[index];
                                return ListTile(
                                  leading: const Icon(Icons.menu_book_rounded),
                                  title: Text(course.title),
                                  subtitle: Text('${course.totalLessons} Lesson'),
                                  trailing: const Icon(Icons.add_circle_outline_rounded),
                                  onTap: () {
                                    context.read<ProgressCubit>().enrollStudent(
                                      EnrollInCourseParams(
                                        studentId: studentId,
                                        courseId: course.id,
                                      ),
                                    );
                                    Navigator.pop(dialogContext);
                                  },
                                );
                              },
                            ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _StudentDetailsLoading extends StatelessWidget {
  const _StudentDetailsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: const [
        SkeletonBox(height: 150, radius: AppRadii.xl),
        SizedBox(height: AppSpacing.sectionGap),
        SkeletonBox(height: 148, radius: AppRadii.xl),
        SizedBox(height: AppSpacing.sectionGap),
        SkeletonBox(height: 178, radius: AppRadii.xl),
      ],
    );
  }
}
