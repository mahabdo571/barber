part of 'business_cubit.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

class BusinessError extends BusinessState {
  final String message;

  const BusinessError(this.message);

  @override
  List<Object?> get props => [message];
}

// Profile States
class BusinessProfileLoaded extends BusinessState {
  final Business business;

  const BusinessProfileLoaded(this.business);

  @override
  List<Object?> get props => [business];
}

class BusinessProfileCreated extends BusinessState {
  final Business business;

  const BusinessProfileCreated(this.business);

  @override
  List<Object?> get props => [business];
}

class BusinessProfileUpdated extends BusinessState {
  final Business business;

  const BusinessProfileUpdated(this.business);

  @override
  List<Object?> get props => [business];
}

// Services States
class BusinessServicesLoaded extends BusinessState {
  final List<Service> services;

  const BusinessServicesLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

// Time Slots States
class BusinessTimeSlotsGenerated extends BusinessState {
  final List<TimeSlot> slots;

  const BusinessTimeSlotsGenerated(this.slots);

  @override
  List<Object?> get props => [slots];
}

class BusinessTimeSlotsLoaded extends BusinessState {
  final List<TimeSlot> slots;

  const BusinessTimeSlotsLoaded(this.slots);

  @override
  List<Object?> get props => [slots];
}

class BusinessTimeSlotUpdated extends BusinessState {}
