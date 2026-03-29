import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/auth/data/models/app_user_model.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';

abstract class AuthDataSource {
  Future<AppUserModel?> getCurrentUser();

  Future<AppUserModel> signInAsRole(UserRole role);

  Future<void> signOut();
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
    );

    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(AppDurations.short);
    _currentUser = null;
  }
}
