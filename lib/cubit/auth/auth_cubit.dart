import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  AuthCubit() : super(AuthInitial());

  void sendOtp(String phoneNumber) async {
    emit(AuthLoading());

    await _auth.verifyPhoneNumber(
      phoneNumber: '+970$phoneNumber',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        emit(AuthSuccess());
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(AuthError(e.message ?? "حدث خطأ"));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        emit(OtpSent());
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void verifyOtp(String otpCode) async {
    emit(AuthLoading());

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      await _auth.signInWithCredential(credential);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError("رمز التحقق غير صحيح"));
    }
  }

  void checkAuthStatus() async {
    emit(AuthChecking());

    final user = _auth.currentUser;
    await Future.delayed(Duration(microseconds: 500));

    if (user != null) {
      emit(AuthSuccess());
    } else {
      emit(AuthInitial());
    }
  }
}
