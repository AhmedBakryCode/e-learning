import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
    this.bio,
    this.phoneNumber,
    this.dateOfBirth,
  });

  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'student'
  final String? profileImageUrl;
  final String? bio;
  final String? phoneNumber;
  final DateTime? dateOfBirth;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    profileImageUrl,
    bio,
    phoneNumber,
    dateOfBirth,
  ];

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? profileImageUrl,
    String? bio,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
