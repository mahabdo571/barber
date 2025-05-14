part of 'customer_cubit.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Profile States
class CustomerProfileLoaded extends CustomerState {
  final Customer customer;

  const CustomerProfileLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerProfileCreated extends CustomerState {
  final Customer customer;

  const CustomerProfileCreated(this.customer);

  @override
  List<Object?> get props => [customer];
}

class CustomerProfileUpdated extends CustomerState {
  final Customer customer;

  const CustomerProfileUpdated(this.customer);

  @override
  List<Object?> get props => [customer];
}

// Booking States
class CustomerBookingsLoaded extends CustomerState {
  final List<Booking> bookings;

  const CustomerBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}
