import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  static const String _verifiedPrefix = "__VERIFIED__:";

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      final isSignedIn = await _authRepository.isSignedIn();
      if (isSignedIn) {
        final userId = await _authRepository.getCurrentUserId();
        if (userId == null) {
          // Should not happen if isSignedIn is true, but good check
          emit(AuthUnauthenticated());
          return;
        }
        final role = await _authRepository.getUserRole();
        if (role == null) {
          emit(AuthNeedsRole(userId));
        } else {
          emit(AuthAuthenticated(role, userId));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('[AuthCubit] Error checking auth status: $e');
      emit(AuthError("خطأ في التحقق من حالة المصادقة: ${e.toString()}"));
    }
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      emit(AuthLoading());
      print('[AuthCubit] Attempting signInWithPhone for: $phoneNumber');

      if (phoneNumber.isEmpty) {
        emit(const AuthError("يرجى إدخال رقم الهاتف"));
        return;
      }
      if (!phoneNumber.startsWith('+')) {
        emit(
          const AuthError("رقم الهاتف يجب أن يبدأ بعلامة + متبوعة برمز البلد"),
        );
        return;
      }

      final resultOrVerificationId = await _authRepository.signInWithPhone(
        phoneNumber,
      );

      if (resultOrVerificationId.startsWith(_verifiedPrefix)) {
        final userId = resultOrVerificationId.substring(_verifiedPrefix.length);
        print('[AuthCubit] Phone auto-verified. UserID: $userId');
        // User is already signed in (e.g., test number), proceed to check role
        final role = await _authRepository.getUserRole();
        if (role != null) {
          emit(AuthAuthenticated(role, userId));
        } else {
          emit(AuthNeedsRole(userId));
        }
      } else {
        // This is a standard verificationId, OTP is needed
        final verificationId = resultOrVerificationId;
        print('[AuthCubit] Code sent. VerificationId: $verificationId');
        emit(AuthCodeSent(verificationId));
      }
    } catch (e) {
      print('[AuthCubit] Error in signInWithPhone: $e');
      emit(
        AuthError(e.toString()),
      ); // e.toString() will be the message from repo's completeError
    }
  }

  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      emit(AuthLoading());
      print(
        '[AuthCubit] Attempting verifyOTP. VerificationId: $verificationId',
      );

      if (otp.length != 6) {
        emit(const AuthError("رمز التحقق يجب أن يتكون من 6 أرقام"));
        return;
      }

      final userId = await _authRepository.verifyOTP(verificationId, otp);
      print('[AuthCubit] OTP verified. UserID: $userId');

      // After OTP verification, user is signed in. Now check role.
      final role = await _authRepository.getUserRole();
      if (role != null) {
        emit(AuthAuthenticated(role, userId));
      } else {
        emit(AuthNeedsRole(userId));
      }
    } catch (e) {
      print('[AuthCubit] Error in verifyOTP: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> setUserRole(String role) async {
    try {
      emit(AuthLoading());
      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) {
        emit(const AuthError("لم يتم العثور على المستخدم لتعيين الدور"));
        return;
      }
      await _authRepository.setUserRole(role);
      print('[AuthCubit] Role ${role} set for UserID: $userId');
      emit(AuthAuthenticated(role, userId));
    } catch (e) {
      print('[AuthCubit] Error setting user role: $e');
      emit(AuthError("خطأ في تعيين دور المستخدم: ${e.toString()}"));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authRepository.signOut();
      print('[AuthCubit] User signed out.');
      emit(AuthUnauthenticated());
    } catch (e) {
      print('[AuthCubit] Error signing out: $e');
      emit(AuthError("خطأ في تسجيل الخروج: ${e.toString()}"));
    }
  }
}
