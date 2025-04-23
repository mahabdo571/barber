// blocs/barber/barber_state.dart

import 'package:equatable/equatable.dart';

abstract class ProfileProviderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileProviderInitial extends ProfileProviderState {}

class ProfileProviderLoading extends ProfileProviderState {}

class ProfileProviderSuccess extends ProfileProviderState {}

class ProfileProviderFailure extends ProfileProviderState {
  final String error;
  ProfileProviderFailure(this.error);

  @override
  List<Object?> get props => [error];
}
