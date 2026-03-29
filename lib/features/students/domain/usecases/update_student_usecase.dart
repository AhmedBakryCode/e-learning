import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateStudentParams extends Equatable {
  const UpdateStudentParams({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.parentPhoneNumber,
    this.password,
    this.profileImagePath,
  });

  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final String? password;
  final String? profileImagePath;

  @override
  List<Object?> get props => [id, name, email, phoneNumber, parentPhoneNumber, password, profileImagePath];
}

class UpdateStudentUseCase implements UseCase<Student, UpdateStudentParams> {
  const UpdateStudentUseCase(this._repository);

  final StudentsRepository _repository;

  @override
  Future<Student> call(UpdateStudentParams params) {
    return _repository.updateStudent(
      id: params.id,
      name: params.name,
      email: params.email,
      phoneNumber: params.phoneNumber,
      parentPhoneNumber: params.parentPhoneNumber,
      password: params.password,
      profileImagePath: params.profileImagePath,
    );
  }
}
