import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:e_learning/features/auth/domain/usecases/sign_in_as_role_usecase.dart';
import 'package:e_learning/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required SignInAsRoleUseCase signInAsRole,
    required SignOutUseCase signOut,
  }) : _getCurrentUser = getCurrentUser,
       _signInAsRole = signInAsRole,
       _signOut = signOut,
       super(const AuthState.initial());

  final GetCurrentUserUseCase _getCurrentUser;
  final SignInAsRoleUseCase _signInAsRole;
  final SignOutUseCase _signOut;

  Future<void> bootstrap() async {
    if (state.status == AuthStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final user = await _getCurrentUser(const NoParams());
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Unable to restore the current session.',
        ),
      );
    }
  }

  Future<void> signInAsRole(UserRole role) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final user = await _signInAsRole(SignInAsRoleParams(role));
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Sign in failed. Please try again.',
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      await _signOut(const NoParams());
      emit(const AuthState(status: AuthStatus.unauthenticated, user: null));
    } catch (_) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          user: state.user,
          errorMessage: 'Sign out failed. Please try again.',
        ),
      );
    }
  }
}
