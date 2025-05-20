import 'package:barber/core/models/error_model.dart';
import 'package:barber/feature/auth/data/auth_repo.dart';
import 'package:barber/feature/auth/models/user_model.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.repo) : super(AuthInitial());
  final AuthRepo repo;
  FirebaseAuthException? err;
  String? savedVerificationId;
  Future<void> sendOtp(String phone) async {
    emit(AuthLoading());
    try {
      await repo.sendOtp(
        phone,
        (v) {
          savedVerificationId = v;
          emit(OtpSent(verificationId: savedVerificationId!));
        },
        (e) {
          err = e;
          emit(AuthFailed(model: ErrorModel(errMessage: e.toString())));
        },
      );
    } catch (e) {
      emit(AuthFailed(model: ErrorModel(errMessage: e.toString())));
    }
  }

  Future<void> verifyOtp(String code) async {
    emit(AuthLoading());
    try {
      final user = await repo.verifyOtp(code, savedVerificationId!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', user.uid);
      emit(AuthSuccess(model: user));
    } catch (e) {
      emit(AuthFailed(model: ErrorModel(errMessage: e.toString())));
    }
  }
}
