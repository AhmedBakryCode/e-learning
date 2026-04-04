import 'dart:io';

import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/profile/domain/entities/profile.dart';
import 'package:e_learning/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileParams {
  const UpdateProfileParams({required this.profile, this.imageFile});

  final Profile profile;
  final File? imageFile;
}

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<void> call(UpdateProfileParams params) =>
      _repository.updateProfile(params.profile, imageFile: params.imageFile);
}

// ..registerFactory(
//       () => ProfileCubit(
//         getProfile: sl<GetProfileUseCase>(),
//         updateProfile: sl<UpdateProfileUseCase>(),
//       ),
//     );
