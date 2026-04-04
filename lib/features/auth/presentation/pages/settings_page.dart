import 'package:e_learning/app/theme/theme_cubit.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/responsive_layout.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final themeMode = context.watch<ThemeCubit>().state;
    final isDarkMode = themeMode == ThemeMode.dark;

    final bodyContent = ListView(
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user == null
                        ? 'NS'
                        : user.name
                              .split(' ')
                              .map((part) => part[0])
                              .take(2)
                              .join(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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
                      user?.name ?? 'Experimental student',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(user?.email ?? 'student@academy.com'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        const SectionHeader(
          title: 'Preferences',
          subtitle:
              'Settings to control the appearance and notifications of the application.',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Edit your personal information',
                trailing: IconButton(
                  onPressed: () {
                    final path = user?.role == UserRole.admin
                        ? '/admin/profile'
                        : '/student/profile';
                    context.push(path);
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
              const Divider(height: AppSpacing.xxl),
              _SettingRow(
                icon: Icons.notifications_active_outlined,
                title: 'Phone notifications',
                subtitle: 'Lesson reminders and Course updates',
                trailing: Switch.adaptive(
                  value: true,
                  onChanged: (val) {
                    // Implement notification toggle logic
                  },
                ),
              ),
              const Divider(height: AppSpacing.xxl),
              _SettingRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark mode',
                subtitle: isDarkMode ? 'Activated' : 'Not activated',
                trailing: Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (val) =>
                      context.read<ThemeCubit>().toggleDarkMode(val),
                ),
              ),
              const Divider(height: AppSpacing.xxl),
              _SettingRow(
                icon: Icons.phone_android_rounded,
                title: 'Matching phone settings',
                subtitle: 'Use system settings for colors and appearance',
                trailing: TextButton(
                  onPressed: () => context.read<ThemeCubit>().useSystemMode(),
                  child: const Text('Activate'),
                ),
              ),
              const Divider(height: AppSpacing.xxl),
              const _SettingRow(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'Arabic',
                trailing: Text(
                  'Activated',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        AppCard(
          title: 'Account',
          subtitle: 'End your current session to return to the login screen.',
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<AuthCubit>().signOut();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        const Center(
          child: Column(
            children: [
              Text(
                'E-Learning App',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Version 1.0.0 (Build 2026.03.30)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );

    return AdaptiveScaffold(
      title: 'Settings',
      subtitle: 'Control your settings and personal data.',
      selectedIndex: 3, // Settings is at index 3
      onNavigationChanged: (index) => _onNavChanged(context, index, user?.role),
      navigationDestinations: _getNavigationDestinations(user?.role),
      body: ResponsiveLayout(
        mobile: bodyContent,
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: bodyContent,
          ),
        ),
      ),
    );
  }

  void _onNavChanged(BuildContext context, int index, UserRole? role) {
    if (role == null) return;
    final basePath = role == UserRole.admin ? '/admin' : '/student';

    switch (index) {
      case 0:
        context.go(basePath);
        break;
      case 1:
        context.go('$basePath/courses');
        break;
      case 2:
        context.go(
          role == UserRole.admin ? '$basePath/students' : '$basePath/progress',
        );
        break;
      case 3:
        context.go('$basePath/settings');
        break;
    }
  }

  List<NavigationDestination> _getNavigationDestinations(UserRole? role) {
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
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
