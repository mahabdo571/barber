import 'package:barber/constants.dart';
import 'package:barber/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  AuthCubit() : super(AuthInitial());

  /// إرسال OTP
  void sendOtp(String phoneNumber) async {
    emit(AuthLoading(authUser: null, role: 'other'));
    await _auth.verifyPhoneNumber(
      phoneNumber: '+970$phoneNumber',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        await _auth.signInWithCredential(cred);
        // مباشرة بعد المصادقة نتحقق من البيانات في Firestore
        await _postSignIn();
      },
      verificationFailed: (e) => emit(AuthError(e.message ?? "حدث خطأ")),
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        emit(OtpSent());
      },
      codeAutoRetrievalTimeout: (id) => _verificationId = id,
    );
  }

  /// التحقق من OTP
  void verifyOtp(String otpCode) async {
    emit(AuthLoading(authUser: null, role: ''));
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      await _auth.signInWithCredential(cred);
      await _postSignIn();
    } catch (_) {
      emit(AuthError("رمز التحقق غير صحيح"));
    }
  }

  /// فحص حالة المصادقة عند الإقلاع
  Future<void> checkAuthStatus() async {
    emit(AuthChecking());

    // 1) تأكد من الاتصال
    var conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) {
      emit(AuthNoInternet());
      await for (var result in Connectivity().onConnectivityChanged) {
        if (result != ConnectivityResult.none) break;
      }
    }

    // 2) اختبار استجابة بسيط
    final sw = Stopwatch()..start();
    try {
      await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      emit(AuthNoInternet());
      return;
    }
    sw.stop();
    if (sw.elapsedMilliseconds > 2000) {
      emit(AuthSlowConnection(latency: sw.elapsedMilliseconds));
    }

    // 3) فحص الجلسة الحالية
    final user = _auth.currentUser;
    if (user != null) {
      await _postSignIn();
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _postSignIn() async {
    final authUser = _auth.currentUser!;
    emit(AuthLoading(authUser: null, role: 'other'));
    final doc = FirebaseFirestore.instance
        .collection(kDBUser)
        .doc(authUser.uid);
    try {
      final snap = await doc.get();
      if (snap.exists) {
        final role = snap.get('role') as String? ?? 'other';
        emit(Authenticated(authUser: authUser, role: role));
      } else {
        emit(AuthIncompleteProfile(authUser: authUser, role: 'other'));
      }
    } catch (_) {
      emit(AuthError("فشل جلب بيانات المستخدم"));
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await getIt.reset();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('خطأ بتسجيل الخروج'));
    }

    getIt.registerSingleton<AuthCubit>(AuthCubit()..checkAuthStatus());
  }
}
