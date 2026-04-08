import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/empty_state_widget.dart';
import 'package:e_learning/core/widgets/loading_indicator.dart';
import 'package:e_learning/core/widgets/responsive_grid.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgressCubit>()..loadProgress(),
      child: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          final isStudent = role == UserRole.student;

          return AdaptiveScaffold(
            title: isStudent ? 'Progressive' : 'Progress analytics',
            subtitle: isStudent
                ? 'Track your current level and achievements.'
                : 'Analytical dashboard of student progress.',
            selectedIndex: isStudent ? 2 : 0,
            onNavigationChanged: isStudent
                ? (index) => _onNavChanged(context, index)
                : null,
            navigationDestinations: isStudent ? _getDestinations() : const [],
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProgressState state) {
    if (state.status == ViewStateStatus.loading) {
      return const LoadingIndicator(label: 'Loading progress...');
    }

    if (state.status == ViewStateStatus.failure) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<ProgressCubit>().loadProgress();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: EmptyStateWidget(
              title: 'Unable to load progress',
              message: state.errorMessage ?? 'Try again shortly.',
              icon: Icons.show_chart_rounded,
              action: FilledButton(
                onPressed: () => context.read<ProgressCubit>().loadProgress(),
                child: const Text('Retry'),
              ),
            ),
          ),
        ),
      );
    }

    if (state.progressItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<ProgressCubit>().loadProgress();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const EmptyStateWidget(
              title: 'There is no progress currently',
              message:
                  'Progress will begin to be recorded once you start watching the Courses.',
              icon: Icons.school_outlined,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProgressCubit>().loadProgress();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          0,
          AppSpacing.pagePadding,
          AppSpacing.huge,
        ),
        children: [
          ResponsiveGrid(
            mobileCrossAxisCount: 1,
            tabletCrossAxisCount: 1,
            desktopCrossAxisCount: 1,
            children: state.progressItems.map((progress) {
              return AppCard(
                title: progress.courseTitle,
                subtitle:
                    'Lesson ${progress.currentLesson} from ${progress.totalLessons}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress.completionPercent,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${(progress.completionPercent * 100).round()}% completed',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _onNavChanged(BuildContext context, int index) {
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

  List<NavigationDestination> _getDestinations() {
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
