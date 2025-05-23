import 'package:barber/feature/auth/data/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _db = FirestoreService();

  @override
  Future<void> sendOtp(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
    Function(FirebaseAuthException e) onFailed,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // ممكن تستخدم auto-login هنا لو حبيت
      },
      verificationFailed: onFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // ممكن تحفظ الـ verificationId لو تأخرت الرسالة
      },
    );
  }

  @override
  Future<UserModel> verifyOtp(
    String smsCode,
    String savedVerificationId,
  ) async {
    final cred = PhoneAuthProvider.credential(
      verificationId: savedVerificationId,
      smsCode: smsCode,
    );
    final user = (await _auth.signInWithCredential(cred)).user!;
    final model = UserModel(uid: user.uid, phone: user.phoneNumber!);
   // await _db.saveUser(model);
    return model;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    var model = await _db.fetchUser(_auth.currentUser!.uid);
    if (model != null) {
      return model;
    }

    return null;
  }

  @override
  Future<bool> isSignedIn() {
    // TODO: implement isSignedIn
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  @override
  Future<bool> saveUserData(UserModel model)async {
 try{
 await _db.saveUser(model);
 return true;
 }catch(e){
  return false;
 }
  }
}
