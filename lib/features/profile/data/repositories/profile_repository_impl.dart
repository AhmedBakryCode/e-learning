import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:e_learning/core/network/api_service.dart';
import 'package:e_learning/features/profile/data/models/profile_model.dart';
import 'package:e_learning/features/profile/domain/entities/profile.dart';
import 'package:e_learning/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._apiClient);

  final ApiService _apiClient;

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _apiClient.get(EndpointConstants.profile);
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(Profile profile, {File? imageFile}) async {
    final Map<String, dynamic> formMap = {
      'Name': profile.name,
      'Email': profile.email,
      'Bio': profile.bio ?? '',
      'PhoneNumber': profile.phoneNumber ?? '',
      if (profile.dateOfBirth != null)
        'DateOfBirth': profile.dateOfBirth!.toIso8601String(),
    };

    if (imageFile != null) {
      formMap['ProfileImage'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      );
    }

    final formData = FormData.fromMap(formMap);
    await _apiClient.put(EndpointConstants.profile, data: formData);
  }

  @override
  Future<String?> uploadProfileImage(String userId, String imagePath) async {
    // Image is now handled in updateProfile via multipart
    return null;
  }
}
