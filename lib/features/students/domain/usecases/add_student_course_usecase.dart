import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';
import 'package:equatable/equatable.dart';

class AddStudentCourseParams extends Equatable {
  const AddStudentCourseParams({
    required this.studentId,
    required this.courseId,
  });

  final String studentId;
  final String courseId;

  @override
  List<Object?> get props => [studentId, courseId];
}

class AddStudentCourseUseCase implements UseCase<void, AddStudentCourseParams> {
  const AddStudentCourseUseCase(this._repository);

  final StudentsRepository _repository;

  @override
  Future<void> call(AddStudentCourseParams params) {
    return _repository.addStudentCourse(
      studentId: params.studentId,
      courseId: params.courseId,
    );
  }
}
