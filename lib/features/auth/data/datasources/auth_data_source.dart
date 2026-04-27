import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:e_learning/core/network/api_service.dart';
import 'package:e_learning/features/auth/data/models/app_user_model.dart';
import 'package:e_learning/features/auth/data/models/login_response_model.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';

abstract class AuthDataSource {
  Future<AppUserModel?> getCurrentUser();

  Future<AppUserModel> signInAsRole(UserRole role);

  Future<LoginResponseModel> login(String email, String password);

  Future<LoginResponseModel> register(
    String name,
    String email,
    String password,
  );

  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  );

  Future<void> signOut();
}

class AuthRemoteDataSource implements AuthDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource(this._apiService);

  @override
  Future<AppUserModel?> getCurrentUser() async {
    // Implement if there's a profile endpoint
    return null;
  }

  @override
  Future<AppUserModel> signInAsRole(UserRole role) async {
    // This is still a mock for internal role switching if needed
    await Future<void>.delayed(AppDurations.medium);
    return AppUserModel(
      id: role == UserRole.admin ? 'admin-001' : 'student-001',
      name: role == UserRole.admin ? 'Ava Teacher' : 'Noah Student',
      email: role == UserRole.admin
          ? 'teacher@elevate.academy'
          : 'student@elevate.academy',
      role: role,
      createdAt: '',
    );
  }

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    final response = await _apiService.post(
      EndpointConstants.login,
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Login failed: ${response.statusMessage}');
    }
  }

  @override
  Future<LoginResponseModel> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _apiService.post(
      EndpointConstants.register,
      data: {'name': name, 'email': email, 'password': password},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Registration failed: ${response.statusMessage}');
    }
  }

  @override
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  ) async {
    final response = await _apiService.post(
      EndpointConstants.refreshToken,
      data: {'accessToken': accessToken, 'refreshToken': refreshToken},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Token refresh failed: ${response.statusMessage}');
    }
  }

  @override
  Future<void> signOut() async {
    // Implement if there's a logout endpoint
  }
}

class MockAuthDataSource implements AuthDataSource {
  AppUserModel? _currentUser;

  @override
  Future<AppUserModel?> getCurrentUser() async {
    await Future<void>.delayed(AppDurations.short);
    return _currentUser;
  }

  @override
  Future<AppUserModel> signInAsRole(UserRole role) async {
    await Future<void>.delayed(AppDurations.medium);

    _currentUser = AppUserModel(
      id: role == UserRole.admin ? 'admin-001' : 'student-001',
      name: role == UserRole.admin ? 'Ava Teacher' : 'Noah Student',
      email: role == UserRole.admin
          ? 'teacher@elevate.academy'
          : 'student@elevate.academy',
      role: role,
      createdAt: '',
    );

    return _currentUser!;
  }

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    await Future<void>.delayed(AppDurations.medium);
    final user = AppUserModel(
      id: 'admin-001',
      name: 'Ava Teacher',
      email: email,
      createdAt: DateTime.now().toIso8601String(),
      role: UserRole.admin,
    );
    return LoginResponseModel(
      token: 'mock-token',
      user: user,
    );
  }

  @override
  Future<LoginResponseModel> register(
    String name,
    String email,
    String password,
  ) async {
    await Future<void>.delayed(AppDurations.medium);
    final user = AppUserModel(
      id: 'student-001',
      name: name,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
      role: UserRole.student,
    );
    return LoginResponseModel(
      token: 'mock-token',
      user: user,
    );
  }

  @override
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  ) async {
    await Future<void>.delayed(AppDurations.short);
    if (_currentUser == null) throw Exception('No user to refresh');
    return LoginResponseModel(
      token: 'mock-refreshed-token',
      user: _currentUser!,
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(AppDurations.short);
    _currentUser = null;
  }
}
