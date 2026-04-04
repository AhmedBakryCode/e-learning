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
    super.profileImageUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      activeCourses: json['activeCourses'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      parentPhoneNumber: json['parentPhoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

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
    String? profileImageUrl,
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
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
