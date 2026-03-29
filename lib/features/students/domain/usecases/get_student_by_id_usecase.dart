import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';
import 'package:equatable/equatable.dart';

class GetStudentByIdParams extends Equatable {
  const GetStudentByIdParams(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class GetStudentByIdUseCase implements UseCase<Student?, GetStudentByIdParams> {
  const GetStudentByIdUseCase(this._repository);

  final StudentsRepository _repository;

  @override
  Future<Student?> call(GetStudentByIdParams params) {
    return _repository.getStudentById(params.id);
  }
}
