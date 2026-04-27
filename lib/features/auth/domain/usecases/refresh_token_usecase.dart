import 'package:e_learning/features/auth/data/models/login_response_model.dart';
import 'package:e_learning/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<LoginResponseModel> call(String accessToken, String refreshToken) {
    return repository.refreshToken(accessToken, refreshToken);
  }
}
