import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class SignInAsRoleParams extends Equatable {
  const SignInAsRoleParams(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

class SignInAsRoleUseCase implements UseCase<AppUser, SignInAsRoleParams> {
  const SignInAsRoleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AppUser> call(SignInAsRoleParams params) {
    return _repository.signInAsRole(params.role);
  }
}
