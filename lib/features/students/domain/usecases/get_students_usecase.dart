import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';

class GetStudentsUseCase implements UseCase<List<Student>, NoParams> {
  const GetStudentsUseCase(this._repository);

  final StudentsRepository _repository;

  @override
  Future<List<Student>> call(NoParams params) {
    return _repository.getStudents();
  }
}
