import 'package:equatable/equatable.dart';

enum UserRole { admin, student }

extension UserRoleX on UserRole {
  String get label => this == UserRole.admin ? 'Admin / Teacher' : 'Student';

  String get dashboardPath => this == UserRole.admin ? '/admin' : '/student';
}

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  @override
  List<Object?> get props => [id, name, email, role];
}
