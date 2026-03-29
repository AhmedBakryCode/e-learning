import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/arabic_mapper.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/skeleton_box.dart';
import 'package:e_learning/core/widgets/status_chip.dart';
import 'package:e_learning/core/widgets/responsive_layout.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/student_course_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/student_course_state.dart';
import 'package:e_learning/features/courses/presentation/widgets/course_video_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StudentCourseDetailsPage extends StatelessWidget {
  const StudentCourseDetailsPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final studentId = context.read<AuthCubit>().state.user?.id;
    if (studentId == null) {
      return const AdaptiveScaffold(
        title: 'Course details',
        subtitle: 'The Course is being prepared.',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (_) => sl<StudentCourseCubit>()..loadCourse(studentId: studentId, courseId: courseId),
      child: BlocBuilder<StudentCourseCubit, StudentCourseState>(
        builder: (context, state) {
          return AdaptiveScaffold(
            title: 'Course details',
            subtitle: 'Track your progress, complete the appropriate lesson, and view all videos.',
            selectedIndex: 1,
            onNavigationChanged: (index) => _onNavChanged(context, index),
            navigationDestinations: _getDestinations(),
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: switch (state.status) {
                ViewStateStatus.loading => const _StudentCourseLoading(),
                ViewStateStatus.failure => EmptyStateWidget(
                    title: 'The Course could not be opened',
                    message: state.errorMessage ?? 'We could not find this Course in the current data.',
                    icon: Icons.school_outlined,
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
      case 0: context.go('/student'); break;
      case 1: context.go('/student/courses'); break;
      case 2: context.go('/student/progress'); break;
    }
  }

  List<NavigationDestination> _getDestinations() {
    return const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
      NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'My Courses'),
      NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Progressive'),
    ];
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.courseId, required this.state});
  final String courseId;
  final StudentCourseState state;

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
        _CourseHeaderCard(courseId: courseId, state: state),
        const SizedBox(height: AppSpacing.sectionGap),
        const SectionHeader(title: 'Videos', subtitle: 'Your personalized learning path.'),
        const SizedBox(height: AppSpacing.lg),
        _VideosList(courseId: courseId, state: state),
        const SizedBox(height: AppSpacing.sectionGap),
        _ResourcesAndDiscussions(courseId: courseId),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.courseId, required this.state});
  final String courseId;
  final StudentCourseState state;

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
              _CourseHeaderCard(courseId: courseId, state: state),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(title: 'Videos', subtitle: 'Course of lessons available in the Course.'),
              const SizedBox(height: AppSpacing.lg),
              _VideosList(courseId: courseId, state: state),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: _ResourcesAndDiscussions(courseId: courseId),
          ),
        ),
      ],
    );
  }
}

class _CourseHeaderCard extends StatelessWidget {
  const _CourseHeaderCard({required this.courseId, required this.state});
  final String courseId;
  final StudentCourseState state;

  @override
  Widget build(BuildContext context) {
    final isEnrolled = state.progress != null;
    final course = state.course!;
    final resumeVideoId = state.resumeVideoId;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        gradient: LinearProgressIndicator(
          value: isEnrolled ? (state.progress?.completionPercent ?? 0) : 0,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withAlpha(20)),
        ).value == 0 ? const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondarySoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : const LinearGradient(
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
                label: ArabicMapper.category(course.category),
                color: Colors.white,
                icon: Icons.auto_awesome_mosaic_rounded,
              ),
              StatusChip(
                label: ArabicMapper.level(course.level),
                color: Colors.white,
                icon: Icons.stars_rounded,
              ),
              if (!isEnrolled)
                const StatusChip(
                  label: 'Not subscribed',
                  color: Colors.white,
                  icon: Icons.lock_outline_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            course.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            course.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withAlpha(210),
                ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (isEnrolled) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: state.progress?.completionPercent ?? 0,
                minHeight: 8,
                backgroundColor: Colors.white.withAlpha(40),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${((state.progress?.completionPercent ?? 0) * 100).round()}% completed - ${course.totalLessons} video',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
            if (state.progress?.lastVideoTitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Latest video: ${state.progress!.lastVideoTitle}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(200)),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: resumeVideoId == null
                      ? null
                      : () => context.push('/student/courses/$courseId/video/$resumeVideoId'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Complete the lesson'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ] else ...[
             const Divider(color: Colors.white24, height: AppSpacing.xxl),
             Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سعر الكورس',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    '1500 EGP',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: Colors.white.withAlpha(50)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'للاشتراك في الكورس، يرجى التواصل مع الإدارة عبر الواتساب أو التليجرام:',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withAlpha(230),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {}, // WhatsApp Action
                                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                                label: const Text('واتساب'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {}, // Telegram Action
                                icon: const Icon(Icons.send_rounded, size: 18),
                                label: const Text('تليجرام'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF0088CC),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _VideosList extends StatelessWidget {
  const _VideosList({required this.courseId, required this.state});
  final String courseId;
  final StudentCourseState state;

  @override
  Widget build(BuildContext context) {
    if (state.videos.isEmpty) {
      return const EmptyStateWidget(
        title: 'There are no videos',
        message: 'No lessons have been added to this Course yet.',
        icon: Icons.video_library_outlined,
      );
    }
    
    final isEnrolled = state.progress != null;
    
    return Column(
      children: state.videos.map((video) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: CourseVideoTile(
            video: video,
            isHighlighted: isEnrolled && video.id == state.lastWatchedVideoId,
            highlightLabel: 'Last seen',
            onTap: isEnrolled 
                ? () => context.push('/student/courses/$courseId/video/${video.id}')
                : null,
            trailing: isEnrolled 
                ? const Icon(Icons.chevron_right_rounded)
                : const Icon(Icons.lock_outline_rounded, color: Colors.grey),
          ),
        );
      }).toList(),
    );
  }
}

class _ResourcesAndDiscussions extends StatelessWidget {
  const _ResourcesAndDiscussions({required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          title: 'Resources',
          subtitle: 'Supporting materials for review and application.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ResourceRow(title: 'Architecture checklist', subtitle: 'PDF file - 8 pages'),
              Divider(height: AppSpacing.xxl),
              _ResourceRow(title: 'Initial design package', subtitle: 'Help attachments'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        AppCard(
          title: 'Discuss the Course',
          subtitle: 'Open the Course discussion or go to comments.',
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.push('/student/courses/$courseId/comments'),
              icon: const Icon(Icons.forum_rounded),
              label: const Text('Open Course comments'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(25),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: const Icon(Icons.description_outlined, color: AppColors.secondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const Icon(Icons.download_rounded),
      ],
    );
  }
}

class _StudentCourseLoading extends StatelessWidget {
  const _StudentCourseLoading();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: const [
        AppCard(child: SkeletonBox(height: 220, radius: AppRadii.xxl)),
        SizedBox(height: AppSpacing.sectionGap),
        SkeletonBox(height: 150, radius: AppRadii.xl),
      ],
    );
  }
}
