import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storage;

  AuthRepositoryImpl(this._storage);

  @override
  Future<String> signInWithPhone(String phoneNumber) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  @override
  Future<String> verifyOTP(String verificationId, String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) throw Exception('Authentication failed');

    // Store the user ID
    await _storage.setString(AppConstants.userIdKey, user.uid);

    return user.uid;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _storage.clear();
  }

  @override
  Future<bool> isSignedIn() async {
    final user = _auth.currentUser;
    final storedUserId = await _storage.getString(AppConstants.userIdKey);
    return user != null && storedUserId != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return await _storage.getString(AppConstants.userIdKey);
  }

  @override
  Future<void> setUserRole(String role) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('User not found');

    await _storage.setString(AppConstants.userRoleKey, role);
    await _storage.setString(AppConstants.userIdKey, userId);
  }

  @override
  Future<String?> getUserRole() async {
    return await _storage.getString(AppConstants.userRoleKey);
  }
}
