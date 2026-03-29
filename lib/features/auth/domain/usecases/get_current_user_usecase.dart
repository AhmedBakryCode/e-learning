import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<AppUser?, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AppUser?> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
