import 'package:e_learning/app/theme/app_colors.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/inline_feedback_card.dart';
import 'package:e_learning/core/widgets/metric_highlight_card.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/status_chip.dart';
import 'package:e_learning/core/widgets/responsive_grid.dart';
import 'package:e_learning/core/widgets/home_components.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:e_learning/features/auth/presentation/cubit/showcase_cubit.dart';
import 'package:e_learning/core/di/service_locator.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ShowcaseCubit>()..loadShowcase(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Teacher control panel',
      subtitle: 'Manage your platform from a smart professional dashboard.',
      selectedIndex: 0,
      onNavigationChanged: (index) => _onNavChanged(context, index),
      navigationDestinations: const [
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
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ShowcaseCubit>().loadShowcase();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            0,
            AppSpacing.pagePadding,
            AppSpacing.huge,
          ),
          children: [
            const HomeShowcasePageView(),
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(
              title: 'Platform summary',
              subtitle: 'Follow the most important indicators before getting into the details.',
            ),
            const SizedBox(height: AppSpacing.lg),
            const ResponsiveGrid(
              mobileCrossAxisCount: 2,
              tabletCrossAxisCount: 2,
              desktopCrossAxisCount: 4,
              children: [
                MetricHighlightCard(
                  title: 'Active Courses',
                  value: '18',
                  subtitle: '6 needs review',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.secondary,
                ),
                MetricHighlightCard(
                  title: 'Monthly revenue',
                  value: '\$42K',
                  subtitle: '12% higher than target',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                ),
                MetricHighlightCard(
                  title: 'Students need follow-up',
                  value: '36',
                  subtitle: 'They need communication',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                MetricHighlightCard(
                  title: 'Unread reports',
                  value: '09',
                  subtitle: 'Comments and reviews',
                  icon: Icons.mark_chat_unread_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            SectionHeader(
              title: 'Fast actions',
              subtitle: 'Go directly to the most frequently used tasks.',
              action: TextButton(
                onPressed: () => context.push('/admin/courses/add'),
                child: const Text('Add a Course'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ResponsiveGrid(
              mobileCrossAxisCount: 2,
              tabletCrossAxisCount: 2,
              desktopCrossAxisCount: 4,
              children: [
                _QuickActionTile(
                  icon: Icons.menu_book_rounded,
                  title: 'Course management',
                  description: 'Organize drafts, published content, and uploads.',
                  color: AppColors.secondary,
                  onTap: () => context.go('/admin/courses'),
                ),
                _QuickActionTile(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Follow students',
                  description: 'See progress, educational status, and groups.',
                  color: AppColors.success,
                  onTap: () => context.go('/admin/students'),
                ),
                _QuickActionTile(
                  icon: Icons.campaign_rounded,
                  title: 'Send notification',
                  description: 'Send alerts, reminders, and updates to all students.',
                  color: AppColors.warning,
                  onTap: () => context.go('/admin/notifications/send'),
                ),
                _QuickActionTile(
                  icon: Icons.settings_rounded,
                  title: 'Application settings',
                  description: 'Manage your profile, theme, and notifications.',
                  color: AppColors.primary,
                  onTap: () => context.go('/admin/settings'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            const SectionHeader(
              title: 'Today',
              subtitle: 'A clear summary of current tasks and next steps.',
            ),
            const SizedBox(height: AppSpacing.lg),
            const InlineFeedbackCard(
              title: 'There are two uploads still in process',
              message:
                  'Artificial Intelligence Course videos require reviewing data and thumbnails before publishing.',
              color: AppColors.warning,
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              title: 'Latest activities',
              subtitle: 'What has been worked on over the past hours?',
              child: Column(
                children: [
                  _TimelineRow(
                    title: 'Flutter Course has been updated for scalable products',
                    subtitle: 'Quality review of the draft has been completed',
                    status: const StatusChip(
                      label: 'Ready',
                      color: AppColors.success,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const Divider(height: AppSpacing.xxl),
                  _TimelineRow(
                    title: 'A student follow-up report has been created',
                    subtitle: '36 students need communication this week',
                    status: const StatusChip(
                      label: 'Important',
                      color: AppColors.warning,
                      icon: Icons.flag_outlined,
                    ),
                  ),
                  const Divider(height: AppSpacing.xxl),
                  _TimelineRow(
                    title: 'A new announcement has been scheduled',
                    subtitle: 'The update will reach all students at 09:00',
                    status: const StatusChip(
                      label: 'Scheduled',
                      color: AppColors.secondary,
                      icon: Icons.schedule_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        context.go('/admin/settings');
        break;
    }
  }

}



class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(35),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final Widget status;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(width: AppSpacing.md),
        status,
      ],
    );
  }
}
