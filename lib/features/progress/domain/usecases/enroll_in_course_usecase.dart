import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';

class EnrollInCourseParams extends Equatable {
  const EnrollInCourseParams({
    required this.studentId,
    required this.courseId,
  });

  final String studentId;
  final String courseId;

  @override
  List<Object?> get props => [studentId, courseId];
}

class EnrollInCourseUseCase implements UseCase<LearningProgress, EnrollInCourseParams> {
  const EnrollInCourseUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<LearningProgress> call(EnrollInCourseParams params) {
    return _repository.enrollInCourse(
      studentId: params.studentId,
      courseId: params.courseId,
    );
  }
}
