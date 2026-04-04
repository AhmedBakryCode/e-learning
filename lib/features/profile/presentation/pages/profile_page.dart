import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/widgets/adaptive_scaffold.dart';
import 'package:e_learning/core/widgets/app_card.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/presentation/widgets/profile_form.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.role});

  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final userRole = role ?? user?.role ?? UserRole.student;
    final isStudent = userRole == UserRole.student;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return BlocProvider(
      create: (context) => sl<ProfileCubit>()..loadProfile(user.id),
      child: AdaptiveScaffold(
        title: 'Profile',
        showBackButton: true,
        selectedIndex: isStudent ? 3 : -1,
        onNavigationChanged: isStudent
            ? (index) => _onStudentNavChanged(context, index)
            : null,
        navigationDestinations: isStudent
            ? _getStudentDestinations()
            : const [],
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.error) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            if (state.profile == null) {
              return const Center(child: Text('Profile not found'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: AppCard(child: ProfileForm(profile: state.profile!)),
            );
          },
        ),
      ),
    );
  }

  void _onStudentNavChanged(BuildContext context, int index) {
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
        // Already on profile/settings
        break;
    }
  }

  List<NavigationDestination> _getStudentDestinations() {
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
