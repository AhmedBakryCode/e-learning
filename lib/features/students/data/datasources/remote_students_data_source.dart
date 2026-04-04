import 'package:dio/dio.dart';
import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:e_learning/core/network/api_service.dart';
import 'package:e_learning/features/students/data/datasources/students_data_source.dart';
import 'package:e_learning/features/students/data/models/student_model.dart';

class RemoteStudentsDataSource implements StudentsDataSource {
  RemoteStudentsDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<List<StudentModel>> getStudents() async {
    final response = await _apiService.get<dynamic>(EndpointConstants.students);

    // Handle both direct list and wrapped {data: [...]} formats
    final List<dynamic> data;
    if (response.data is List) {
      data = response.data as List<dynamic>;
    } else if (response.data is Map<String, dynamic>) {
      data =
          (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ??
          [];
    } else {
      data = [];
    }

    return data
        .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    final path = EndpointConstants.studentById.replaceAll('{id}', id);
    final response = await _apiService.get<Map<String, dynamic>>(path);

    if (response.data == null) return null;
    return StudentModel.fromJson(response.data!);
  }

  @override
  Future<StudentModel> addStudent({
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  }) async {
    final formData = FormData.fromMap({
      'Name': name,
      'Email': email,
      if (password != null && password.isNotEmpty) 'Password': password,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'PhoneNumber': phoneNumber,
      if (parentPhoneNumber != null && parentPhoneNumber.isNotEmpty)
        'ParentPhoneNumber': parentPhoneNumber,
      if (profileImagePath != null && profileImagePath.isNotEmpty)
        'ProfileImage': await MultipartFile.fromFile(profileImagePath),
    });

    final response = await _apiService.post<Map<String, dynamic>>(
      EndpointConstants.students,
      data: formData,
    );

    return StudentModel.fromJson(response.data!);
  }

  @override
  Future<StudentModel> updateStudent({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    String? parentPhoneNumber,
    String? password,
    String? profileImagePath,
  }) async {
    final path = EndpointConstants.studentById.replaceAll('{id}', id);

    final formData = FormData.fromMap({
      if (name.isNotEmpty) 'Name': name,
      if (email.isNotEmpty) 'Email': email,
      if (password != null && password.isNotEmpty) 'Password': password,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'PhoneNumber': phoneNumber,
      if (parentPhoneNumber != null && parentPhoneNumber.isNotEmpty)
        'ParentPhoneNumber': parentPhoneNumber,
      if (profileImagePath != null && profileImagePath.isNotEmpty)
        'ProfileImage': await MultipartFile.fromFile(profileImagePath),
    });

    final response = await _apiService.put<Map<String, dynamic>>(
      path,
      data: formData,
    );

    return StudentModel.fromJson(response.data!);
  }

  @override
  Future<void> deleteStudent(String id) async {
    final path = EndpointConstants.studentById.replaceAll('{id}', id);
    await _apiService.delete(path);
  }

  Future<void> addStudentCourse({
    required String studentId,
    required String courseId,
  }) async {
    final path = EndpointConstants.studentCourses.replaceAll('{id}', studentId);
    await _apiService.post(path, data: {'courseId': courseId});
  }

  Future<List<StudentModel>> getTopStudents({int limit = 5}) async {
    final response = await _apiService.get<dynamic>(
      EndpointConstants.topStudents,
      queryParameters: {'limit': limit},
    );

    // Handle both direct list and wrapped {data: [...]} formats
    final List<dynamic> data;
    if (response.data is List) {
      data = response.data as List<dynamic>;
    } else if (response.data is Map<String, dynamic>) {
      data =
          (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ??
          [];
    } else {
      data = [];
    }

    return data
        .map((json) => StudentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
