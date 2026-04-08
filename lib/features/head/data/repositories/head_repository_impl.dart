import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:e_learning/core/network/api_service.dart';
import 'package:e_learning/features/head/data/models/head_model.dart';
import 'package:e_learning/features/head/domain/entities/head.dart';
import 'package:e_learning/features/head/domain/repositories/head_repository.dart';

class HeadRepositoryImpl implements HeadRepository {
  final ApiService _apiService;

  HeadRepositoryImpl(this._apiService);

  @override
  Future<List<Head>> getHeads() async {
    final response = await _apiService.get(EndpointConstants.head);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((item) => HeadModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createHead({
    required String title,
    required String name,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'Title': title,
      'Name': name,
      'Image': await MultipartFile.fromFile(image.path),
    });
    await _apiService.post(EndpointConstants.head, data: formData);
  }

  @override
  Future<void> updateHead({
    required String id,
    required String title,
    required String name,
    File? image,
  }) async {
    final Map<String, dynamic> formDataMap = {
      'Title': title,
      'Name': name,
    };

    if (image != null) {
      formDataMap['Image'] = await MultipartFile.fromFile(image.path);
    }

    final formData = FormData.fromMap(formDataMap);
    await _apiService.put(
      EndpointConstants.headById.replaceFirst('{id}', id),
      data: formData,
    );
  }

  @override
  Future<void> deleteHead(String id) async {
    await _apiService.delete(EndpointConstants.headById.replaceFirst('{id}', id));
  }
}
