part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}
final class AuthUnauthenticated extends AuthState {}
final class AuthCustomer  extends AuthState {
    final String userId ;

  AuthCustomer({required this.userId});
}
final class AuthCompany  extends AuthState {
  final String userId ;

  AuthCompany({required this.userId});

}
final class isProfileComplete  extends AuthState {
   User? user;

  isProfileComplete({ this.user});

}

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
