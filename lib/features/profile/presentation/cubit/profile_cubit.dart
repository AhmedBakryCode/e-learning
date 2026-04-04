import 'dart:io';

import 'package:e_learning/features/profile/domain/entities/profile.dart';
import 'package:e_learning/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:e_learning/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetProfileUseCase getProfile,
    required UpdateProfileUseCase updateProfile,
  }) : _getProfile = getProfile,
       _updateProfile = updateProfile,
       super(const ProfileState.initial());

  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  Future<void> loadProfile(String userId) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _getProfile(userId);
      if (profile != null) {
        emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'Profile not found',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> updateProfile(Profile profile, {File? imageFile}) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    try {
      await _updateProfile(
        UpdateProfileParams(profile: profile, imageFile: imageFile),
      );
      emit(state.copyWith(status: ProfileStatus.updated, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
