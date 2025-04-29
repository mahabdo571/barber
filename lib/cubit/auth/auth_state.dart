import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {}

class AuthNoInternet extends AuthState {}

class AuthSlowConnection extends AuthState {
  final int latency;

  AuthSlowConnection({required this.latency});
}

class AuthSuccess extends AuthState {
  final String role;

  AuthSuccess({required this.role});
}
class AuthIncompleteProfile extends AuthState {}

class AuthChecking extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
