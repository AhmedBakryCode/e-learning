import 'package:e_learning/features/students/data/datasources/remote_students_data_source.dart';
import 'package:e_learning/features/students/data/datasources/students_data_source.dart';
import 'package:e_learning/features/students/domain/entities/student.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  const StudentsRepositoryImpl({required StudentsDataSource dataSource})
    : _dataSource = dataSource;

  final StudentsDataSource _dataSource;

  @override
  Future<List<Student>> getStudents() {
    return _dataSource.getStudents();
  }

  @override
  Future<Student?> getStudentById(String id) {
    return _dataSource.getStudentById(id);
  }

  @override
  Future<Student> addStudent({
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  }) {
    return _dataSource.addStudent(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      parentPhoneNumber: parentPhoneNumber,
      password: password,
      profileImagePath: profileImagePath,
    );
  }

  @override
  Future<Student> updateStudent({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  }) {
    return _dataSource.updateStudent(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      parentPhoneNumber: parentPhoneNumber,
      password: password,
      profileImagePath: profileImagePath,
    );
  }

  @override
  Future<void> deleteStudent(String id) {
    return _dataSource.deleteStudent(id);
  }

  @override
  Future<void> addStudentCourse({
    required String studentId,
    required String courseId,
  }) async {
    if (_dataSource case final RemoteStudentsDataSource remoteSource) {
      return remoteSource.addStudentCourse(
        studentId: studentId,
        courseId: courseId,
      );
    }
    throw UnimplementedError(
      'addStudentCourse only available with remote data source',
    );
  }

  @override
  Future<List<Student>> getTopStudents({int limit = 5}) async {
    if (_dataSource case final RemoteStudentsDataSource remoteSource) {
      return remoteSource.getTopStudents(limit: limit);
    }
    throw UnimplementedError(
      'getTopStudents only available with remote data source',
    );
  }
}
