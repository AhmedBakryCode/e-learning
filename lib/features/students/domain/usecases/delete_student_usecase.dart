import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';
import 'package:equatable/equatable.dart';

class DeleteStudentParams extends Equatable {
  const DeleteStudentParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class DeleteStudentUseCase implements UseCase<void, DeleteStudentParams> {
  const DeleteStudentUseCase(this._repository);

  final StudentsRepository _repository;

  @override
  Future<void> call(DeleteStudentParams params) {
    return _repository.deleteStudent(params.id);
  }
}
