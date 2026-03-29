import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:equatable/equatable.dart';

class GetCoursesParams extends Equatable {
  const GetCoursesParams({required this.role});

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

class GetCoursesUseCase implements UseCase<List<Course>, GetCoursesParams> {
  const GetCoursesUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<List<Course>> call(GetCoursesParams params) {
    return _repository.getCourses(role: params.role);
  }
}
