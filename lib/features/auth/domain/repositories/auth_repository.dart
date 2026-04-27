import 'package:e_learning/features/auth/data/models/login_response_model.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();

  Future<AppUser> signInAsRole(UserRole role);

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
