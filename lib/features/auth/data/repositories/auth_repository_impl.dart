import 'package:e_learning/features/auth/data/datasources/auth_data_source.dart';
import 'package:e_learning/features/auth/data/models/login_response_model.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthDataSource dataSource})
    : _dataSource = dataSource;

  final AuthDataSource _dataSource;

  @override
  Future<AppUser?> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }

  @override
  Future<AppUser> signInAsRole(UserRole role) {
    return _dataSource.signInAsRole(role);
  }

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    final response = await _dataSource.login(email, password);
    return response;
  }

  @override
  Future<LoginResponseModel> register(
    String name,
    String email,
    String password,
  ) async {
    return _dataSource.register(name, email, password);
  }

  @override
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  ) async {
    return _dataSource.refreshToken(accessToken, refreshToken);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}
