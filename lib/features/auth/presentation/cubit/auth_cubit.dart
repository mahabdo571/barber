import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkAuthStatus(); // Auto-check auth status when cubit is created
  }

  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      final isSignedIn = await _authRepository.isSignedIn();

      if (isSignedIn) {
        final userId = await _authRepository.getCurrentUserId();
        final role = await _authRepository.getUserRole();

        if (userId != null && role != null) {
          emit(AuthAuthenticated(role, userId));
        } else if (userId != null) {
          emit(AuthNeedsRole(userId));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      emit(AuthLoading());
      final verificationId = await _authRepository.signInWithPhone(phoneNumber);
      emit(AuthCodeSent(verificationId));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      emit(AuthLoading());
      final userId = await _authRepository.verifyOTP(verificationId, otp);
      emit(AuthNeedsRole(userId));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> setUserRole(String role) async {
    try {
      emit(AuthLoading());
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) throw Exception('User not found');

      await _authRepository.setUserRole(role);
      emit(AuthAuthenticated(role, userId));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
