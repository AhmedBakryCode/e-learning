import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';
import 'package:equatable/equatable.dart';

class AddStudentParams extends Equatable {
  const AddStudentParams({
    required this.name,
    required this.email,
    this.phoneNumber,
    this.parentPhoneNumber,
    this.password,
    this.profileImagePath,
  });

  final String name;
  final String email;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final String? password;
  final String? profileImagePath;

  @override
  List<Object?> get props => [name, email, phoneNumber, parentPhoneNumber, password, profileImagePath];
}

class AddStudentUseCase implements UseCase<Student, AddStudentParams> {
  const AddStudentUseCase(this._repository);

  final StudentsRepository _repository;

  @override
  Future<Student> call(AddStudentParams params) {
    return _repository.addStudent(
      name: params.name,
      email: params.email,
      phoneNumber: params.phoneNumber,
      parentPhoneNumber: params.parentPhoneNumber,
      password: params.password,
      profileImagePath: params.profileImagePath,
    );
  }
}
