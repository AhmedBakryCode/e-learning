import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/core/network/session_manager.dart';
import 'package:e_learning/features/auth/data/models/app_user_model.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_learning/features/auth/domain/usecases/sign_in_as_role_usecase.dart';
import 'package:e_learning/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase login,
    required SignInAsRoleUseCase signInAsRole,
    required SignOutUseCase signOut,
    required SessionManager sessionManager,
  }) : _login = login,
       _signInAsRole = signInAsRole,
       _signOut = signOut,
       _sessionManager = sessionManager,
       super(const AuthState.initial());

  final LoginUseCase _login;
  final SignInAsRoleUseCase _signInAsRole;
  final SignOutUseCase _signOut;
  final SessionManager _sessionManager;

  Future<void> bootstrap() async {
    if (state.status == AuthStatus.loading) {
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final user = _sessionManager.getUser();
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

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final response = await _login(email, password);
      await _sessionManager.saveSession(response.token, response.user);
      emit(AuthState(status: AuthStatus.authenticated, user: response.user));
    } catch (e) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Login failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> signInAsRole(UserRole role) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final user = await _signInAsRole(SignInAsRoleParams(role));
      if (user is AppUserModel) {
        await _sessionManager.saveSession('dummy-token', user);
      }
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
      await _sessionManager.clearSession();
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

  void updateUser(AppUser user) {
    if (state.status == AuthStatus.authenticated) {
      emit(state.copyWith(user: user));
    }
  }
}
