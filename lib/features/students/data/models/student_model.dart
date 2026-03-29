import 'package:e_learning/features/students/domain/entities/student.dart';

class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.email,
    required super.activeCourses,
    required super.completionRate,
    super.phoneNumber,
    super.parentPhoneNumber,
    super.password,
    super.profileImagePath,
  });

  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    int? activeCourses,
    double? completionRate,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      activeCourses: activeCourses ?? this.activeCourses,
      completionRate: completionRate ?? this.completionRate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
