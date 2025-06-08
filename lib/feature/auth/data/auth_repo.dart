import 'package:firebase_auth/firebase_auth.dart';

import '../../users/models/user_model.dart';

abstract class AuthRepo {
  Future<void> sendOtp(
     String phone,
    Function(String verificationId) onCodeSent,
     Function(FirebaseAuthException e) onFailed
    );
  Future<UserModel> verifyOtp(String smsCode,String savedVerificationId);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<UserModel?> getCurrentUser();
  Future<bool> saveUserData(Object? model);

}
