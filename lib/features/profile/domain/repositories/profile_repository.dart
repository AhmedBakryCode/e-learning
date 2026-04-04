import 'dart:io';

import 'package:e_learning/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<void> updateProfile(Profile profile, {File? imageFile});
  Future<String?> uploadProfileImage(String userId, String imagePath);
}
