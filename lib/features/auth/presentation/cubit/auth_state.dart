part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthNeedsRole extends AuthState {
  final String userId;

  const AuthNeedsRole(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AuthCodeSent extends AuthState {
  final String verificationId;

  const AuthCodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class AuthAuthenticated extends AuthState {
  final String role;
  final String userId;

  const AuthAuthenticated(this.role, this.userId);

  @override
  List<Object?> get props => [role, userId];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
