import 'package:e_learning/app/theme/theme_cubit.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/section_header.dart';
import 'package:e_learning/core/widgets/responsive_layout.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
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
                    user == null ? 'NS' : user.name.split(' ').map((part) => part[0]).take(2).join(),
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
                    Text(user?.name ?? 'Experimental student', style: Theme.of(context).textTheme.titleLarge),
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
          subtitle: 'Settings to control the appearance and notifications of the application.',
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.notifications_active_outlined,
                title: 'Phone notifications',
                subtitle: 'Lesson reminders and Course updates',
                trailing: Switch.adaptive(value: true, onChanged: (_) {}),
              ),
              const Divider(height: AppSpacing.xxl),
              _SettingRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark mode',
                subtitle: isDarkMode ? 'Activated' : 'Not activated',
                trailing: Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (val) => context.read<ThemeCubit>().toggleDarkMode(val),
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
                trailing: Text('Activated', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        AppCard(
          title: 'Account',
          subtitle: 'End your current session to return to the login screen.',
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
    );

    return AdaptiveScaffold(
      title: 'Settings',
      subtitle: 'Control your settings and personal data.',
      selectedIndex: -1, // Use standard back navigation
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
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
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
        trailing,
      ],
    );
  }
}
