import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) {
    return _repository.signOut();
  }
}
