import 'package:e_learning/features/auth/data/models/login_response_model.dart';
import 'package:e_learning/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<LoginResponseModel> call(String name, String email, String password) {
    return repository.register(name, email, password);
  }
}
