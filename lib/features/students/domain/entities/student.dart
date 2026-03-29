import 'package:equatable/equatable.dart';

class Student extends Equatable {
  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.activeCourses,
    required this.completionRate,
    this.phoneNumber,
    this.parentPhoneNumber,
    this.password,
    this.profileImagePath,
  });

  final String id;
  final String name;
  final String email;
  final int activeCourses;
  final double completionRate;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final String? password;
  final String? profileImagePath;

  @override
  List<Object?> get props => [
    id, 
    name, 
    email, 
    activeCourses, 
    completionRate, 
    phoneNumber, 
    parentPhoneNumber, 
    password,
    profileImagePath,
  ];
}
