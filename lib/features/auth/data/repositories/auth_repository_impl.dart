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
    print('[AuthRepo] signInWithPhone called with: $phoneNumber');
    // Check if number format is correct
    if (!phoneNumber.startsWith('+')) {
      print('[AuthRepo] Invalid phone number format: $phoneNumber');
      throw Exception('رقم الهاتف يجب أن يبدأ بعلامة + ورمز البلد');
    }

    final completer = Completer<String>();
    var didTimeout = false;
    Timer?
    timeoutTimer; // Make timer nullable to ensure it's cancelled properly

    timeoutTimer = Timer(const Duration(seconds: 60), () {
      print('[AuthRepo] 60s timeoutTimer fired.');
      didTimeout = true;
      if (!completer.isCompleted) {
        print(
          '[AuthRepo] Completer not completed by timeoutTimer, completing with error.',
        );
        completer.completeError('انتهى وقت التحقق. يرجى المحاولة مرة أخرى.');
      } else {
        print(
          '[AuthRepo] Completer already completed when timeoutTimer fired.',
        );
      }
    });

    try {
      print('[AuthRepo] Calling _auth.verifyPhoneNumber for $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(
          seconds: 60,
        ), // Firebase internal timeout for auto-retrieval
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('[AuthRepo] verificationCompleted callback received.');
          timeoutTimer?.cancel();
          if (didTimeout) {
            print(
              '[AuthRepo] verificationCompleted: didTimeout is true, returning to avoid issues.',
            );
            return;
          }
          try {
            print(
              '[AuthRepo] verificationCompleted: Attempting signInWithCredential.',
            );
            final userCredential = await _auth.signInWithCredential(credential);
            final user = userCredential.user;
            print(
              '[AuthRepo] verificationCompleted: signInWithCredential completed, user: ${user?.uid}',
            );

            if (user != null) {
              if (!completer.isCompleted) {
                await _storage.setString(AppConstants.userIdKey, user.uid);
                await _storage.setString(
                  AppConstants.userPhoneKey,
                  user.phoneNumber ?? '',
                );
                print(
                  '[AuthRepo] verificationCompleted: Completing completer with __VERIFIED__:${user.uid}',
                );
                completer.complete("__VERIFIED__:${user.uid}");
              } else {
                print(
                  '[AuthRepo] verificationCompleted: Completer already completed (user != null).',
                );
              }
            } else {
              if (!completer.isCompleted) {
                print(
                  '[AuthRepo] verificationCompleted: User is null after signInWithCredential, completing with error.',
                );
                completer.completeError('فشل التحقق التلقائي (المستخدم فارغ)');
              } else {
                print(
                  '[AuthRepo] verificationCompleted: Completer already completed (user == null).',
                );
              }
            }
          } catch (e) {
            print(
              '[AuthRepo] verificationCompleted: Error during signInWithCredential: $e',
            );
            if (!completer.isCompleted) {
              completer.completeError(
                'خطأ في التحقق التلقائي: ${e.toString()}',
              );
            } else {
              print(
                '[AuthRepo] verificationCompleted: Completer already completed (error during signIn).',
              );
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print(
            '[AuthRepo] verificationFailed callback received: Code: ${e.code}, Message: ${e.message}',
          );
          timeoutTimer?.cancel();
          if (!completer.isCompleted) {
            String errorMsg = 'فشل التحقق من رقم الهاتف';
            if (e.code == 'invalid-phone-number') {
              errorMsg = 'رقم الهاتف المقدم غير صحيح. تأكد من تضمين رمز البلد.';
            } else if (e.code == 'too-many-requests') {
              errorMsg =
                  'تم إرسال عدد كبير جدا من الطلبات. يرجى المحاولة لاحقاً.';
            } else if (e.code == 'network-request-failed') {
              errorMsg =
                  'خطأ في الاتصال بالشبكة. يرجى التحقق من اتصالك بالإنترنت.';
            } else if (e.code == 'internal-error' &&
                e.message?.contains('MISSING_CLIENT_ID') == true) {
              errorMsg = 'خطأ في إعدادات Firebase. يرجى مراجعة مسؤول التطبيق.';
            } else if (e.message?.contains('RECAPTCHA_INVALID_SITE_KEY') ==
                    true ||
                e.message?.contains('safety_net_token') == true) {
              errorMsg =
                  'مشكلة في التحقق الأمني (reCAPTCHA/SafetyNet). تحقق من إعدادات SHA في Firebase.';
            }
            print(
              '[AuthRepo] verificationFailed: Completing completer with error: $errorMsg',
            );
            completer.completeError(errorMsg);
          } else {
            print(
              '[AuthRepo] verificationFailed: Completer already completed.',
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print(
            '[AuthRepo] codeSent callback received. VerificationId: $verificationId, ResendToken: $resendToken',
          );
          // Do NOT cancel timeoutTimer here; we are waiting for OTP.
          if (!completer.isCompleted) {
            print(
              '[AuthRepo] codeSent: Completing completer with verificationId: $verificationId',
            );
            completer.complete(verificationId);
          } else {
            print('[AuthRepo] codeSent: Completer already completed.');
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print(
            '[AuthRepo] codeAutoRetrievalTimeout callback received for VerificationId: $verificationId',
          );
          // This callback means Firebase's auto-retrieval timed out.
          // Our main `timeoutTimer` handles the overall operation timeout.
          // We don't want to complete the completer here unless our main timer also fired.
          if (didTimeout && !completer.isCompleted) {
            print(
              '[AuthRepo] codeAutoRetrievalTimeout: Main timeout (didTimeout) is true. Completing with error.',
            );
            completer.completeError(
              'انتهى وقت استرداد الرمز تلقائياً. يرجى المحاولة مرة أخرى.',
            );
          } else {
            print(
              '[AuthRepo] codeAutoRetrievalTimeout: Main timeout not reached or completer handled. No action.',
            );
          }
        },
      );
      print(
        '[AuthRepo] _auth.verifyPhoneNumber call presumably succeeded in initiating.',
      );
    } catch (e) {
      print('[AuthRepo] Error directly calling _auth.verifyPhoneNumber: $e');
      timeoutTimer?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          'حدث خطأ غير متوقع أثناء بدء عملية التحقق: ${e.toString()}',
        );
      } else {
        print(
          '[AuthRepo] Error calling verifyPhoneNumber: Completer already completed.',
        );
      }
    }

    return completer.future;
  }

  @override
  Future<String> verifyOTP(String verificationId, String otp) async {
    print(
      '[AuthRepo] verifyOTP called. VerificationId: $verificationId, OTP: $otp',
    );
    try {
      if (otp.length != 6) {
        print('[AuthRepo] Invalid OTP length.');
        throw Exception('الرمز يجب أن يتكون من 6 أرقام');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      print('[AuthRepo] Attempting signInWithCredential with OTP.');
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        print('[AuthRepo] User is null after signInWithCredential with OTP.');
        throw Exception('فشل التحقق من الهوية (المستخدم فارغ بعد OTP)');
      }

      await _storage.setString(AppConstants.userIdKey, user.uid);
      await _storage.setString(
        AppConstants.userPhoneKey,
        user.phoneNumber ?? '',
      );
      print('[AuthRepo] OTP verified successfully. UserID: ${user.uid}');
      return user.uid;
    } catch (e) {
      print('[AuthRepo] Error verifying OTP: $e');
      String errorMsg = 'فشل التحقق من الرمز المدخل';
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          errorMsg = 'رمز التحقق المدخل غير صحيح.';
        } else if (e.code == 'session-expired') {
          errorMsg = 'انتهت صلاحية جلسة التحقق. يرجى طلب رمز جديد.';
        } else if (e.code == 'invalid-verification-id') {
          errorMsg =
              'معرف جلسة التحقق غير صالح. قد تحتاج إلى إعادة إرسال الرمز.';
        }
      }
      throw Exception(errorMsg);
    }
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
    if (userId == null) throw Exception('لم يتم العثور على المستخدم');

    await _storage.setString(AppConstants.userRoleKey, role);
    await _storage.setString(
      AppConstants.userIdKey,
      userId,
    ); // Ensure userId is still set, though it should be
  }

  @override
  Future<String?> getUserRole() async {
    return await _storage.getString(AppConstants.userRoleKey);
  }
}
