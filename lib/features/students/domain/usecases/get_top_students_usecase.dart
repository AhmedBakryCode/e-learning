import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';
import 'package:equatable/equatable.dart';

class GetTopStudentsParams extends Equatable {
  const GetTopStudentsParams({this.limit = 5});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class GetTopStudentsUseCase implements UseCase<List<Student>, GetTopStudentsParams> {
  const GetTopStudentsUseCase(this._repository);

  final StudentsRepository _repository;

  @override
  Future<List<Student>> call(GetTopStudentsParams params) {
    return _repository.getTopStudents(limit: params.limit);
  }
}
