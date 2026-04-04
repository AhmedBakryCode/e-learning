import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/profile/domain/repositories/profile_repository.dart';

class UploadProfileImageUseCase implements UseCase<String?, UploadImageParams> {
  UploadProfileImageUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<String?> call(UploadImageParams params) =>
      _repository.uploadProfileImage(params.userId, params.imagePath);
}

class UploadImageParams {
  const UploadImageParams(this.userId, this.imagePath);

  final String userId;
  final String imagePath;
}
