// blocs/barber/barber_state.dart

import 'package:equatable/equatable.dart';

abstract class BarberState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BarberInitial extends BarberState {}

class BarberLoading extends BarberState {}

class BarberSuccess extends BarberState {}

class BarberFailure extends BarberState {
  final String error;
  BarberFailure(this.error);

  @override
  List<Object?> get props => [error];
}
