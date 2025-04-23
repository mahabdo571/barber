// blocs/barber/barber_state.dart

import 'package:equatable/equatable.dart';

abstract class ProviderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProviderSuccess extends ProviderState {}

class ProviderFailure extends ProviderState {
  final String error;
  ProviderFailure(this.error);

  @override
  List<Object?> get props => [error];
}
