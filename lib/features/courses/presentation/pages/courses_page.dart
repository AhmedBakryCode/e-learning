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
import 'package:e_learning/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_state.dart';
import 'package:e_learning/core/widgets/responsive_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
            title: role == UserRole.admin
                ? 'Course management'
                : 'Course library',
            subtitle: role == UserRole.admin
                ? 'Manage content quality, drafts, videos, and publishing status.'
                : 'Browse educational paths with clear progress indicators.',
            selectedIndex: 2,
            onNavigationChanged: (index) => _onNavChanged(context, role, index),
            navigationDestinations: destinations,
            floatingActionButton: role == UserRole.admin
                ? FloatingActionButton.extended(
                    onPressed: () => context.push('/admin/courses/add'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add a Course'),
                  )
                : null,
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
      case 3:
        context.go('/student/settings');
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
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings_rounded),
        label: 'Settings',
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
    return RefreshIndicator(
      onRefresh: () async {
        final futures = <Future>[context.read<CoursesCubit>().loadCourses(role)];
        if (role == UserRole.student) {
          final user = context.read<AuthCubit>().state.user;
          futures.add(
            context.read<ProgressCubit>().loadProgress(studentId: user?.id),
          );
        }
        await Future.wait(futures);
      },
      child: ListView(
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
          if (role == UserRole.admin) ...[
            const SectionHeader(
              title: 'Control menu',
              subtitle:
                  'Click the arrow for quick access to edit or review options.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _AdminCoursesList(state: state),
          ] else
            BlocBuilder<ProgressCubit, ProgressState>(
              builder: (context, progressState) {
                final myCourses = state.filteredCourses
                    .where((course) => course.isFeatured)
                    .toList();

                final otherCourses = state.filteredCourses
                    .where((course) => !course.isFeatured)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'My Enrolled Courses',
                      subtitle: 'Access all videos and track your progress.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (myCourses.isEmpty)
                      const EmptyStateWidget(
                        title: 'You are not subscribed to any course',
                        message:
                            'Explore available courses below and contact us to enroll.',
                        icon: Icons.school_outlined,
                      )
                    else
                      ResponsiveGrid(
                        mobileCrossAxisCount: 1,
                        tabletCrossAxisCount: 2,
                        desktopCrossAxisCount: 3,
                        children: myCourses
                            .map(
                              (course) => CourseCard(
                                course: course,
                                role: role,
                                actionLabel: 'Continue Learning',
                                onTap: () =>
                                    _openCourse(context, role, course.id),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: AppSpacing.xxxl),

                    const SectionHeader(
                      title: 'Available Courses',
                      subtitle:
                          'Contact us via WhatsApp or Telegram to enroll: 01065406332',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (otherCourses.isEmpty)
                      const EmptyStateWidget(
                        title: 'No available courses at the moment',
                        message:
                            'All courses are currently available for enrollment. Check back soon!',
                        icon: Icons.check_circle_outline_rounded,
                      )
                    else
                      ResponsiveGrid(
                        mobileCrossAxisCount: 1,
                        tabletCrossAxisCount: 2,
                        desktopCrossAxisCount: 3,
                        children: otherCourses
                            .map(
                              (course) => _NonEnrolledCourseCard(
                                course: course,
                                onContact: () =>
                                    _showContactOptions(context, course.title),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _openCourse(BuildContext context, UserRole role, String courseId) {
    context.push(
      role == UserRole.admin
          ? '/admin/courses/$courseId'
          : '/student/courses/$courseId',
    );
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
        message:
            'Try a different filter or add a new Course to expand this list.',
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
                      await context.read<CoursesCubit>().deleteCourse(
                        course.id,
                      );
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit the chorus')),
                  PopupMenuItem(value: 'video', child: Text('Add video')),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete the Course'),
                  ),
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
    context.push(
      role == UserRole.admin
          ? '/admin/courses/$courseId'
          : '/student/courses/$courseId',
    );
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

class _NonEnrolledCourseCard extends StatelessWidget {
  const _NonEnrolledCourseCard({required this.course, required this.onContact});

  final dynamic course;
  final VoidCallback onContact;

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Development':
        return Icons.code_rounded;
      case 'Design':
        return Icons.palette_outlined;
      case 'Analytics':
        return Icons.analytics_outlined;
      case 'AI':
        return Icons.auto_awesome_rounded;
      case 'Teaching':
        return Icons.school_outlined;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Development':
        return const Color(0xFF3B82F6);
      case 'Design':
        return const Color(0xFFEC4899);
      case 'Analytics':
        return const Color(0xFFF59E0B);
      case 'AI':
        return const Color(0xFF8B5CF6);
      case 'Teaching':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF1C1E22);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _categoryColor(course.category);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Course Image
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              image: course.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(course.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: course.imageUrl == null
                ? Center(
                    child: Icon(
                      _categoryIcon(course.category),
                      color: accentColor,
                      size: 40,
                    ),
                  )
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    _categoryIcon(course.category),
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        course.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  course.description ?? 'No description available',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline_rounded,
                      label: course.instructorName,
                    ),
                    _InfoChip(
                      icon: Icons.play_lesson_rounded,
                      label: '${course.totalLessons}',
                    ),
                    _InfoChip(
                      icon: Icons.star_rounded,
                      label: course.rating.toStringAsFixed(1),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: onContact,
                  icon: const Icon(Icons.contact_support_outlined, size: 18),
                  label: const Text('Contact to Enroll'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

void _showContactOptions(BuildContext context, String courseTitle) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enroll in $courseTitle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Contact us via WhatsApp or Telegram to enroll in this course.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(Icons.chat, color: Color(0xFF25D366)),
              ),
              title: const Text('WhatsApp'),
              subtitle: const Text('01065406332'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchWhatsApp(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF0088CC).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(Icons.send, color: Color(0xFF0088CC)),
              ),
              title: const Text('Telegram'),
              subtitle: const Text('01065406332'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchTelegram(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _launchWhatsApp(BuildContext context) async {
  final Uri uri = Uri.parse('https://wa.me/201065406332');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }
}

Future<void> _launchTelegram(BuildContext context) async {
  final Uri uri = Uri.parse('https://t.me/+201065406332');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open Telegram')));
    }
  }
}
