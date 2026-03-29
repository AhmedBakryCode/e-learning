import 'package:e_learning/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();

  Future<AppUser> signInAsRole(UserRole role);

  Future<void> signOut();
}
