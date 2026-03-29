import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteCourseParams extends Equatable {
  const DeleteCourseParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class DeleteCourseUseCase implements UseCase<void, DeleteCourseParams> {
  const DeleteCourseUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<void> call(DeleteCourseParams params) {
    return _repository.deleteCourse(params.id);
  }
}
