import 'package:barber/constants.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

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

  // void checkAuthStatus() async {
  //   emit(AuthChecking());

  //   final user = _auth.currentUser;
  //   await Future.delayed(Duration(seconds: 1));

  //   if (user != null) {
  //     emit(AuthSuccess());
  //   } else {
  //     emit(AuthInitial());
  //   }
  // }

  Future<void> checkAuthStatus() async {
    emit(AuthChecking());

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(AuthNoInternet());
      await for (final result in Connectivity().onConnectivityChanged) {
        if (result != ConnectivityResult.none) break;
      }
      return checkAuthStatus();
    }

    final stopwatch = Stopwatch()..start();
    try {
      await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();
    } catch (e) {
      emit(AuthNoInternet());
      return;
    }
    final latencyMs = stopwatch.elapsedMilliseconds;

  
    if (latencyMs > 2000) {
      emit(AuthSlowConnection(latency: latencyMs));
      
    }

   
    final user = await getCurrentUser();
    // Future.delayed(Duration(microseconds: 500));
    if (user != null) {
      
    await checkIfUserExists(user.uid);
      
    } else {
      emit(AuthInitial());
    }
  }

     Future<void> checkIfUserExists(String uid) async {
  final docRef = FirebaseFirestore.instance.collection('Users').doc(uid);

  try {
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      emit(AuthSuccess()); 
    } else {
      emit(AuthIncompleteProfile()); 
    }
  } catch (e) {
    emit(AuthError("فشل جلب بيانات المستخدم"));
  }
}
}
