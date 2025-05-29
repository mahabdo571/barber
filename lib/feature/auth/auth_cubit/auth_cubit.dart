import 'dart:developer';

import 'package:barber/core/models/error_model.dart';
import 'package:barber/feature/auth/data/auth_repo.dart';
import 'package:barber/feature/auth/models/store_model.dart';
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
      if (await repo.getCurrentUser() == null) {
        emit(AuthSuccess(model: user));
      } else {
        checkAuthAndRole(user);
      }
    } catch (e) {
      emit(AuthFailed(model: ErrorModel(errMessage: e.toString())));
    }
  }

  Future<void> checkisProfileComplete() async {
    final user = FirebaseAuth.instance.currentUser;
    if (await repo.getCurrentUser() == null) {
      emit(isProfileComplete(user: user));
    }
  }

  Future<void> checkAuthAndRole(UserModel? user) async {
    if (await repo.getCurrentUser() != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }
      final tknRes = await user.getIdTokenResult(true);
      final role = tknRes.claims?['role'] as String?;

      if (role == 'company'){
        emit(AuthCompany(userId: user.uid));
      }
      else if (role == 'customer'){
        emit(AuthCustomer());
      }
      else{
        emit(AuthUnauthenticated());
    }
    }
  }

  Future<void> signOut() async {
    await repo.signOut();

    emit(AuthUnauthenticated());
  }

  Future<void> saveData(StoreModel model) async {
    await repo.saveUserData(model);
    checkAuthAndRole(null);
  }
}
