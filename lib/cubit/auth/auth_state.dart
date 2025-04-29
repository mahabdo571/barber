import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthState {
  /// لو في ID للمستخدم بعد التوثيق
  User? get authUser => null;
  /// لو في دور مخزّن
  String? get role => null;
}

/// حالة أولية قبل أي شيء
class AuthInitial extends AuthState {}

/// أثناء محاولة الاتصال بالإنترنت أو إرسال OTP
class AuthLoading extends AuthState {}

/// تم إرسال الـ OTP بنجاح
class OtpSent extends AuthState {}

/// التحقق من بيانات المستخدم (مثلاً جلب من SharedPreferences أو FirebaseAuth)
class AuthChecking extends AuthState {}

/// لا يوجد اتصال بالإنترنت
class AuthNoInternet extends AuthState {}

/// سرعة الاتصال بطيئة
class AuthSlowConnection extends AuthState {
  final int latency;
  AuthSlowConnection({required this.latency});
}

/// التوثيق غير مكتمل (مثلاً لا توجد بيانات البروفايل)
class AuthIncompleteProfile extends AuthState {}

/// حالة توثيق ناجح
class Authenticated extends AuthState {
  @override
  final User? authUser;
  @override
  final String role;

  Authenticated({required this.authUser, required this.role});
}

/// حالة المستخدم غير موثّق
class Unauthenticated extends AuthState {}

/// عند وقوع خطأ
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
