import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/profile/domain/entities/profile.dart';
import 'package:e_learning/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<Profile?, String> {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile?> call(String userId) => _repository.getProfile(userId);
}
