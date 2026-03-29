import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:equatable/equatable.dart';

class GetCourseByIdParams extends Equatable {
  const GetCourseByIdParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class GetCourseByIdUseCase implements UseCase<Course?, GetCourseByIdParams> {
  const GetCourseByIdUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Course?> call(GetCourseByIdParams params) {
    return _repository.getCourseById(params.id);
  }
}
