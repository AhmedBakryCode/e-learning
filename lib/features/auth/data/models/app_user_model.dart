import 'package:e_learning/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.createdAt,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: (json['role'] as String) == 'admin'
          ? UserRole.admin
          : UserRole.student,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'name': name, 
      'email': email, 
      'role': role.name,
      'createdAt': createdAt,
    };
  }
}
