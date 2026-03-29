import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:equatable/equatable.dart';

class StudentDashboardState extends Equatable {
  const StudentDashboardState({
    this.status = ViewStateStatus.initial,
    this.enrolledCourses = const [],
    this.continueCourse,
    this.continueProgress,
    this.errorMessage,
  });

  final ViewStateStatus status;
  final List<Course> enrolledCourses;
  final Course? continueCourse;
  final LearningProgress? continueProgress;
  final String? errorMessage;

  StudentDashboardState copyWith({
    ViewStateStatus? status,
    List<Course>? enrolledCourses,
    Course? continueCourse,
    LearningProgress? continueProgress,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return StudentDashboardState(
      status: status ?? this.status,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      continueCourse: continueCourse ?? this.continueCourse,
      continueProgress: continueProgress ?? this.continueProgress,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    enrolledCourses,
    continueCourse,
    continueProgress,
    errorMessage,
  ];
}
