import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {}

class AuthSuccess extends AuthState {}
class AuthChecking extends AuthState {} 


class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
