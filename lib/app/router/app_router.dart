import 'package:e_learning/app/router/go_router_refresh_stream.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_state.dart';
import 'package:e_learning/features/auth/presentation/pages/admin_dashboard_page.dart';
import 'package:e_learning/features/auth/presentation/pages/login_page.dart';
import 'package:e_learning/features/auth/presentation/pages/settings_page.dart';
import 'package:e_learning/features/auth/presentation/pages/splash_page.dart';
import 'package:e_learning/features/auth/presentation/pages/student_dashboard_page.dart';
import 'package:e_learning/features/comments/presentation/pages/comments_page.dart';
import 'package:e_learning/features/courses/presentation/pages/add_video_page.dart';
import 'package:e_learning/features/courses/presentation/pages/admin_course_details_page.dart';
import 'package:e_learning/features/courses/presentation/pages/admin_course_form_page.dart';
import 'package:e_learning/features/courses/presentation/pages/courses_page.dart';
import 'package:e_learning/features/courses/presentation/pages/student_course_details_page.dart';
import 'package:e_learning/features/courses/presentation/pages/video_player_page.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:e_learning/features/notifications/presentation/pages/notifications_page.dart';
import 'package:e_learning/features/notifications/presentation/pages/notifications_sender_page.dart';
import 'package:e_learning/features/notifications/presentation/pages/student_notification_details_page.dart';
import 'package:e_learning/features/notifications/domain/entities/learning_notification.dart';
import 'package:e_learning/features/payment/presentation/pages/payment_page.dart';
import 'package:e_learning/features/profile/presentation/pages/profile_page.dart';
import 'package:e_learning/features/progress/presentation/pages/progress_page.dart';
import 'package:e_learning/features/students/presentation/pages/admin_student_form_page.dart';
import 'package:e_learning/features/students/presentation/pages/student_details_page.dart';
import 'package:e_learning/features/students/presentation/pages/students_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter(this._authCubit);

  final AuthCubit _authCubit;

  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String adminPath = '/admin';
  static const String studentPath = '/student';

  late final GoRouter router = GoRouter(
    initialLocation: splashPath,
    refreshListenable: GoRouterRefreshStream(_authCubit.stream),
    routes: [
      GoRoute(
        path: splashPath,
        pageBuilder: (context, state) => _page(state, const SplashPage()),
      ),
      GoRoute(
        path: loginPath,
        pageBuilder: (context, state) => _page(state, const LoginPage()),
      ),
      GoRoute(
        path: adminPath,
        pageBuilder: (context, state) =>
            _page(state, const AdminDashboardPage()),
      ),
      GoRoute(
        path: '$adminPath/courses',
        pageBuilder: (context, state) =>
            _page(state, const CoursesPage(role: UserRole.admin)),
      ),
      GoRoute(
        path: '$adminPath/courses/add',
        pageBuilder: (context, state) =>
            _page(state, const AdminCourseFormPage()),
      ),
      GoRoute(
        path: '$adminPath/courses/:courseId',
        pageBuilder: (context, state) => _page(
          state,
          AdminCourseDetailsPage(courseId: state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '$adminPath/courses/:courseId/edit',
        pageBuilder: (context, state) => _page(
          state,
          AdminCourseFormPage(courseId: state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '$adminPath/courses/:courseId/videos/add',
        pageBuilder: (context, state) => _page(
          state,
          AddVideoPage(courseId: state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '$adminPath/students',
        pageBuilder: (context, state) => _page(state, const StudentsPage()),
      ),
      GoRoute(
        path: '$adminPath/students/add',
        pageBuilder: (context, state) =>
            _page(state, const AdminStudentFormPage()),
      ),
      GoRoute(
        path: '$adminPath/students/:studentId',
        pageBuilder: (context, state) => _page(
          state,
          StudentDetailsPage(studentId: state.pathParameters['studentId']!),
        ),
      ),
      GoRoute(
        path: '$adminPath/students/:studentId/edit',
        pageBuilder: (context, state) => _page(
          state,
          AdminStudentFormPage(studentId: state.pathParameters['studentId']!),
        ),
      ),
      GoRoute(
        path: '$adminPath/notifications',
        redirect: (context, state) => '$adminPath/notifications/send',
      ),
      GoRoute(
        path: '$adminPath/notifications/send',
        pageBuilder: (context, state) =>
            _page(state, const NotificationsSenderPage()),
      ),
      GoRoute(
        path: '$adminPath/progress',
        pageBuilder: (context, state) =>
            _page(state, const ProgressPage(role: UserRole.admin)),
      ),
      GoRoute(
        path: '$adminPath/profile',
        pageBuilder: (context, state) => _page(state, const ProfilePage()),
      ),
      GoRoute(
        path: '$adminPath/settings',
        pageBuilder: (context, state) => _page(state, const SettingsPage()),
      ),
      GoRoute(
        path: studentPath,
        pageBuilder: (context, state) =>
            _page(state, const StudentDashboardPage()),
      ),
      GoRoute(
        path: '$studentPath/courses',
        pageBuilder: (context, state) =>
            _page(state, const CoursesPage(role: UserRole.student)),
      ),
      GoRoute(
        path: '$studentPath/courses/:courseId',
        pageBuilder: (context, state) => _page(
          state,
          StudentCourseDetailsPage(courseId: state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '$studentPath/courses/:courseId/payment',
        pageBuilder: (context, state) => _page(
          state,
          PaymentPage(courseId: state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '$studentPath/courses/:courseId/video/:videoId',
        pageBuilder: (context, state) => _page(
          state,
          VideoPlayerPage(
            courseId: state.pathParameters['courseId']!,
            videoId: state.pathParameters['videoId']!,
          ),
        ),
      ),
      GoRoute(
        path: '$studentPath/courses/:courseId/comments',
        pageBuilder: (context, state) => _page(
          state,
          CommentsPage(
            role: UserRole.student,
            courseId: state.pathParameters['courseId']!,
            videoId: state.uri.queryParameters['videoId'],
          ),
        ),
      ),
      GoRoute(
        path: '$studentPath/notifications',
        pageBuilder: (context, state) =>
            _page(state, const NotificationsPage(role: UserRole.student)),
      ),
      GoRoute(
        path: '$studentPath/notifications/:notificationId',
        pageBuilder: (context, state) {
          final notification = state.extra as LearningNotification;
          return _page(
            state,
            BlocProvider(
              create: (_) => sl<NotificationsCubit>(),
              child: StudentNotificationDetailsPage(notification: notification),
            ),
          );
        },
      ),
      GoRoute(
        path: '$studentPath/settings',
        pageBuilder: (context, state) => _page(state, const SettingsPage()),
      ),
      GoRoute(
        path: '$studentPath/profile',
        pageBuilder: (context, state) =>
            _page(state, const ProfilePage(role: UserRole.student)),
      ),
      GoRoute(
        path: '$studentPath/progress',
        pageBuilder: (context, state) =>
            _page(state, const ProgressPage(role: UserRole.student)),
      ),
    ],
    redirect: (_, state) {
      final location = state.matchedLocation;
      final authState = _authCubit.state;
      final isLoading =
          authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;

      if (isLoading) {
        return location == splashPath ? null : splashPath;
      }

      if (authState.status == AuthStatus.unauthenticated ||
          authState.user == null) {
        return location == loginPath ? null : loginPath;
      }

      final homePath = _homePathForRole(authState.user!.role);

      if (location == splashPath || location == loginPath) {
        return homePath;
      }

      if (authState.user!.role == UserRole.admin &&
          location.startsWith(studentPath)) {
        return adminPath;
      }

      if (authState.user!.role == UserRole.student &&
          location.startsWith(adminPath)) {
        return studentPath;
      }

      return null;
    },
  );

  String _homePathForRole(UserRole role) {
    return role == UserRole.admin ? adminPath : studentPath;
  }

  CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
