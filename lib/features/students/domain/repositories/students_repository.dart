import 'package:e_learning/features/students/domain/entities/student.dart';

abstract class StudentsRepository {
  Future<List<Student>> getStudents();

  Future<Student?> getStudentById(String id);

  Future<Student> addStudent({
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  });

  Future<Student> updateStudent({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  });

  Future<void> deleteStudent(String id);

  Future<void> addStudentCourse({
    required String studentId,
    required String courseId,
  });

  Future<List<Student>> getTopStudents({int limit});
}
