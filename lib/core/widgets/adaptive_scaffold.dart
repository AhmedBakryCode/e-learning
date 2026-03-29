import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/utils/responsive_utils.dart';
import 'package:e_learning/core/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
    this.navigationDestinations = const [],
    this.onNavigationChanged,
    this.selectedIndex = 0,
    this.floatingActionButton,
    this.headerTrailing,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final List<NavigationDestination> navigationDestinations;
  final ValueChanged<int>? onNavigationChanged;
  final int selectedIndex;
  final Widget? floatingActionButton;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileScaffold(
        title: title,
        subtitle: subtitle,
        body: body,
        actions: actions,
        navigationDestinations: navigationDestinations,
        onNavigationChanged: onNavigationChanged,
        selectedIndex: selectedIndex,
        floatingActionButton: floatingActionButton,
        headerTrailing: headerTrailing,
      ),
      tablet: _TabletScaffold(
        title: title,
        subtitle: subtitle,
        body: body,
        actions: actions,
        navigationDestinations: navigationDestinations,
        onNavigationChanged: onNavigationChanged,
        selectedIndex: selectedIndex,
        floatingActionButton: floatingActionButton,
        headerTrailing: headerTrailing,
      ),
      desktop: _DesktopScaffold(
        title: title,
        subtitle: subtitle,
        body: body,
        actions: actions,
        navigationDestinations: navigationDestinations,
        onNavigationChanged: onNavigationChanged,
        selectedIndex: selectedIndex,
        floatingActionButton: floatingActionButton,
        headerTrailing: headerTrailing,
      ),
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold({
    required this.title,
    this.subtitle,
    required this.body,
    this.actions = const [],
    this.navigationDestinations = const [],
    this.onNavigationChanged,
    this.selectedIndex = 0,
    this.floatingActionButton,
    this.headerTrailing,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final List<NavigationDestination> navigationDestinations;
  final ValueChanged<int>? onNavigationChanged;
  final int selectedIndex;
  final Widget? floatingActionButton;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: navigationDestinations.isEmpty
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onNavigationChanged,
              destinations: navigationDestinations,
            ),
      body: _BaseBody(
        title: title,
        subtitle: subtitle,
        body: body,
        actions: actions,
        headerTrailing: headerTrailing,
      ),
    );
  }
}

class _TabletScaffold extends StatelessWidget {
  const _TabletScaffold({
    required this.title,
    this.subtitle,
    required this.body,
    this.actions = const [],
    this.navigationDestinations = const [],
    this.onNavigationChanged,
    this.selectedIndex = 0,
    this.floatingActionButton,
    this.headerTrailing,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final List<NavigationDestination> navigationDestinations;
  final ValueChanged<int>? onNavigationChanged;
  final int selectedIndex;
  final Widget? floatingActionButton;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          if (navigationDestinations.isNotEmpty)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onNavigationChanged,
              labelType: NavigationRailLabelType.all,
              destinations: navigationDestinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
          Expanded(
            child: _BaseBody(
              title: title,
              subtitle: subtitle,
              body: body,
              actions: actions,
              headerTrailing: headerTrailing,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({
    required this.title,
    this.subtitle,
    required this.body,
    this.actions = const [],
    this.navigationDestinations = const [],
    this.onNavigationChanged,
    this.selectedIndex = 0,
    this.floatingActionButton,
    this.headerTrailing,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final List<NavigationDestination> navigationDestinations;
  final ValueChanged<int>? onNavigationChanged;
  final int selectedIndex;
  final Widget? floatingActionButton;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (navigationDestinations.isNotEmpty)
            _Sidebar(
              destinations: navigationDestinations,
              selectedIndex: selectedIndex,
              onNavigationChanged: onNavigationChanged,
            ),
          Expanded(
            child: Column(
              children: [
                _DesktopTopbar(
                  title: title,
                  subtitle: subtitle,
                  actions: actions,
                  headerTrailing: headerTrailing,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.pageMaxWidth,
                      ),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destinations,
    required this.selectedIndex,
    this.onNavigationChanged,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onNavigationChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'E-Learning',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: destinations.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final d = destinations[index];
                final isSelected = index == selectedIndex;

                return InkWell(
                  onTap: () => onNavigationChanged?.call(index),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primaryContainer : null,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Row(
                      children: [
                        isSelected ? (d.selectedIcon ?? d.icon) : d.icon,
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected ? colorScheme.primary : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopTopbar extends StatelessWidget {
  const _DesktopTopbar({
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.headerTrailing,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const Spacer(),
          if (headerTrailing != null) ...[
            headerTrailing!,
            const SizedBox(width: AppSpacing.md),
          ],
          ...actions,
          const SizedBox(width: AppSpacing.md),
          const CircleAvatar(
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}

class _BaseBody extends StatelessWidget {
  const _BaseBody({
    required this.title,
    this.subtitle,
    required this.body,
    this.actions = const [],
    this.headerTrailing,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.sm,
                AppSpacing.pagePadding,
                AppSpacing.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (headerTrailing != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    headerTrailing!,
                  ],
                  ...actions,
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
