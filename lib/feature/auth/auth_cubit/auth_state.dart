part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class OtpSent extends AuthState {
  final String verificationId;

  OtpSent({required this.verificationId});
}

final class AuthFailed extends AuthState {
  final ErrorModel model;

  AuthFailed({required this.model});
}

final class AuthSuccess extends AuthState {
  final UserModel model;

  AuthSuccess({required this.model});
}
