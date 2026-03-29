import 'package:e_learning/features/auth/data/datasources/auth_data_source.dart';
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
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}
