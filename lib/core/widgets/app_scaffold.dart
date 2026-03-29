import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.headerTrailing,
    this.headerPadding,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? headerTrailing;
  final EdgeInsetsGeometry? headerPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: DecoratedBox(
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
          bottom: bottomNavigationBar == null,
          child: Column(
            children: [
              Padding(
                padding:
                    headerPadding ??
                    const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.sm,
                      AppSpacing.pagePadding,
                      AppSpacing.lg,
                    ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LeadingSlot(leading: leading),
                    if (leading != null) const SizedBox(width: AppSpacing.md),
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
      ),
    );
  }
}

class _LeadingSlot extends StatelessWidget {
  const _LeadingSlot({this.leading});

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    if (leading != null) {
      return leading!;
    }

    final fallbackLocation = _fallbackLocation(context);
    final canGoBack =
        Navigator.of(context).canPop() || fallbackLocation != null;

    if (!canGoBack) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.card,
      ),
      child: IconButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).maybePop();
            return;
          }

          if (fallbackLocation != null) {
            context.go(fallbackLocation);
          }
        },
        icon: const BackButtonIcon(),
      ),
    );
  }

  String? _fallbackLocation(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final segments = Uri.parse(location).pathSegments;

    switch (location) {
      case '/student/courses':
      case '/student/progress':
        return '/student';
      case '/admin/progress':
        return '/admin';
    }

    if (segments.length == 3 &&
        segments[0] == 'admin' &&
        segments[1] == 'courses') {
      return '/admin/courses';
    }

    if (segments.length == 4 &&
        segments[0] == 'admin' &&
        segments[1] == 'courses' &&
        segments[3] == 'edit') {
      return '/admin/courses/${segments[2]}';
    }

    if (segments.length == 5 &&
        segments[0] == 'admin' &&
        segments[1] == 'courses' &&
        segments[3] == 'videos' &&
        segments[4] == 'add') {
      return '/admin/courses/${segments[2]}';
    }

    if (segments.length == 3 &&
        segments[0] == 'admin' &&
        segments[1] == 'students') {
      return '/admin/students';
    }

    if (segments.length == 4 &&
        segments[0] == 'admin' &&
        segments[1] == 'students' &&
        segments[3] == 'edit') {
      return '/admin/students/${segments[2]}';
    }

    if (segments.length == 3 &&
        segments[0] == 'student' &&
        segments[1] == 'courses') {
      return '/student/courses';
    }

    if (segments.length == 4 &&
        segments[0] == 'student' &&
        segments[1] == 'courses' &&
        segments[3] == 'comments') {
      return '/student/courses/${segments[2]}';
    }

    if (segments.length == 5 &&
        segments[0] == 'student' &&
        segments[1] == 'courses' &&
        segments[3] == 'video') {
      return '/student/courses/${segments[2]}';
    }

    return null;
  }
}
