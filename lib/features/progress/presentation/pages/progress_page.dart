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
            subtitle: isStudent ? 'Track your current level and achievements.' : 'Analytical dashboard of student progress.',
            selectedIndex: isStudent ? 2 : 0,
            onNavigationChanged: isStudent ? (index) => _onNavChanged(context, index) : null,
            navigationDestinations: isStudent ? _getDestinations() : const [],
            body: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: _buildBody(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProgressState state) {
    if (state.status == ViewStateStatus.loading) {
      return const LoadingIndicator(label: 'Loading progress...');
    }

    if (state.status == ViewStateStatus.failure) {
      return EmptyStateWidget(
        title: 'Unable to load progress',
        message: state.errorMessage ?? 'Try again shortly.',
        icon: Icons.show_chart_rounded,
      );
    }

    if (state.progressItems.isEmpty) {
      return const EmptyStateWidget(
        title: 'There is no progress currently',
        message: 'Progress will begin to be recorded once you start watching the Courses.',
        icon: Icons.school_outlined,
      );
    }

    return ListView(
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
              subtitle: 'Lesson ${progress.currentLesson} from ${progress.totalLessons}',
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
