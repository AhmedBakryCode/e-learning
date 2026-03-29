import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/students/data/models/student_model.dart';

abstract class StudentsDataSource {
  Future<List<StudentModel>> getStudents();

  Future<StudentModel?> getStudentById(String id);

  Future<StudentModel> addStudent({
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  });

  Future<StudentModel> updateStudent({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  });

  Future<void> deleteStudent(String id);
}

class MockStudentsDataSource implements StudentsDataSource {
  const MockStudentsDataSource();

  static final List<StudentModel> _students = [
    StudentModel(
      id: 'student-001',
      name: 'Olivia Harper',
      email: 'olivia@academy.com',
      activeCourses: 4,
      completionRate: 0.81,
    ),
    StudentModel(
      id: 'student-002',
      name: 'Mason Reed',
      email: 'mason@academy.com',
      activeCourses: 3,
      completionRate: 0.64,
    ),
    StudentModel(
      id: 'student-003',
      name: 'Sophia Lane',
      email: 'sophia@academy.com',
      activeCourses: 5,
      completionRate: 0.92,
    ),
  ];

  static List<StudentModel> get catalog =>
      List<StudentModel>.unmodifiable(_students);

  static StudentModel? findStudent(String id) {
    final index = _students.indexWhere((student) => student.id == id);
    return index == -1 ? null : _students[index];
  }

  static void updateMetrics({
    required String studentId,
    required int activeCourses,
    required double completionRate,
  }) {
    final index = _students.indexWhere((student) => student.id == studentId);
    if (index == -1) {
      return;
    }

    _students[index] = _students[index].copyWith(
      activeCourses: activeCourses,
      completionRate: completionRate,
    );
  }

  /// Returns the top students sorted by completionRate descending.
  static List<StudentModel> getTopStudentsByCompletion({int limit = 5}) {
    final sorted = List<StudentModel>.from(_students)
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<StudentModel>> getStudents() async {
    await Future<void>.delayed(AppDurations.short);
    return List<StudentModel>.from(_students);
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    await Future<void>.delayed(AppDurations.short);
    return findStudent(id);
  }

  @override
  Future<StudentModel> addStudent({
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  }) async {
    await Future<void>.delayed(AppDurations.medium);

    final student = StudentModel(
      id: 'student-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      activeCourses: 0,
      completionRate: 0,
      phoneNumber: phoneNumber,
      parentPhoneNumber: parentPhoneNumber,
      password: password,
      profileImagePath: profileImagePath,
    );

    _students.insert(0, student);
    return student;
  }

  @override
  Future<StudentModel> updateStudent({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  }) async {
    await Future<void>.delayed(AppDurations.medium);

    final index = _students.indexWhere((student) => student.id == id);
    if (index == -1) {
      throw StateError('Student not found');
    }

    final updated = _students[index].copyWith(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      parentPhoneNumber: parentPhoneNumber,
      password: password,
      profileImagePath: profileImagePath,
    );
    _students[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteStudent(String id) async {
    await Future<void>.delayed(AppDurations.medium);
    _students.removeWhere((student) => student.id == id);
  }
}
