import 'dart:async';
import 'dart:io';

import 'package:e_learning/features/profile/domain/entities/profile.dart';
import 'package:e_learning/features/profile/domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  Profile? _mockProfile;

  @override
  Future<Profile?> getProfile(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    _mockProfile ??= Profile(
      id: userId,
      name: 'Ahmed Bakry',
      email: 'ahmed.bakry@example.com',
      role: 'student',
      bio: 'Future Software Engineer | Flutter Enthusiast',
      phoneNumber: '+201234567890',
      dateOfBirth: DateTime(2002, 5, 15),
      profileImageUrl: 'https://i.pravatar.cc/150?u=$userId',
    );

    return _mockProfile;
  }

  @override
  Future<void> updateProfile(Profile profile, {File? imageFile}) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    _mockProfile = profile;
  }

  @override
  Future<String?> uploadProfileImage(String userId, String imagePath) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // In mock, we just return a new pravatar URL based on current timestamp
    final newUrl =
        'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}';
    if (_mockProfile != null) {
      _mockProfile = _mockProfile!.copyWith(profileImageUrl: newUrl);
    }
    return newUrl;
  }
}
