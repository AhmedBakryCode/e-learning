import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/presentation/cubit/student_dashboard_state.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/usecases/get_progress_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDashboardCubit extends Cubit<StudentDashboardState> {
  StudentDashboardCubit({
    required GetCoursesUseCase getCourses,
    required GetProgressUseCase getProgress,
  }) : _getCourses = getCourses,
       _getProgress = getProgress,
       super(const StudentDashboardState());

  final GetCoursesUseCase _getCourses;
  final GetProgressUseCase _getProgress;

  Future<void> loadDashboard(String studentId) async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    try {
      final courses = await _getCourses(
        const GetCoursesParams(role: UserRole.student),
      );
      final progressItems = await _getProgress(
        GetProgressParams(studentId: studentId),
      );
      final progressByCourse = {
        for (final item in progressItems) item.courseId: item,
      };

      final enrolledCourses = courses
          .where((course) => progressByCourse.containsKey(course.id))
          .map((course) {
            final progress = progressByCourse[course.id];
            return course.copyWith(
              completionPercent: progress?.completionPercent ?? 0,
              totalLessons: progress?.totalLessons ?? course.totalLessons,
            );
          })
          .toList();

      final continueProgress = _pickContinueProgress(progressItems);
      final continueCourse = continueProgress == null
          ? (enrolledCourses.isEmpty ? null : enrolledCourses.first)
          : _findCourse(enrolledCourses, continueProgress.courseId);

      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          enrolledCourses: enrolledCourses,
          continueCourse: continueCourse,
          continueProgress: continueProgress,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load your courses right now.',
        ),
      );
    }
  }

  LearningProgress? _pickContinueProgress(List<LearningProgress> items) {
    final candidates = items
        .where(
          (item) => item.completionPercent > 0 && item.completionPercent < 1,
        )
        .toList();
    if (candidates.isEmpty) {
      return items.isEmpty ? null : items.first;
    }

    candidates.sort(
      (a, b) => (b.completionPercent * 1000).round().compareTo(
        (a.completionPercent * 1000).round(),
      ),
    );
    return candidates.first;
  }

  Course? _findCourse(List<Course> courses, String courseId) {
    final index = courses.indexWhere((course) => course.id == courseId);
    return index == -1 ? null : courses[index];
  }
}
