part of 'customer_cubit.dart';

abstract class CustomerState extends Equatable {
  final String? message;

  const CustomerState({this.message});

  @override
  List<Object?> get props => [message];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial() : super();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading() : super();
}

class CustomerError extends CustomerState {
  @override
  final String message;

  const CustomerError(String error) : message = error, super(message: error);

  @override
  List<Object?> get props => [message];
}

// Profile States
class CustomerProfileLoaded extends CustomerState {
  final Customer customer;

  const CustomerProfileLoaded(this.customer, {String? message})
    : super(message: message);

  @override
  List<Object?> get props => [customer, message];
}

class CustomerProfileCreated extends CustomerState {
  final Customer customer;

  const CustomerProfileCreated(this.customer)
    : super(message: 'Profile created successfully.');

  @override
  List<Object?> get props => [customer, message];
}

class CustomerProfileUpdated extends CustomerState {
  final Customer customer;

  const CustomerProfileUpdated(this.customer)
    : super(message: 'Profile updated successfully.');

  @override
  List<Object?> get props => [customer, message];
}

// Business States
class CustomerFavoritesLoaded extends CustomerState {
  final List<Business> businesses;

  const CustomerFavoritesLoaded(this.businesses, {String? message})
    : super(message: message);

  @override
  List<Object?> get props => [businesses, message];
}

class CustomerBusinessDetailsLoaded extends CustomerState {
  final Business business;
  final List<Service> services;

  const CustomerBusinessDetailsLoaded(
    this.business,
    this.services, {
    String? message,
  }) : super(message: message);

  @override
  List<Object?> get props => [business, services, message];
}

class CustomerTimeSlotsLoaded extends CustomerState {
  final List<TimeSlot> slots;

  const CustomerTimeSlotsLoaded(this.slots, {String? message})
    : super(message: message);

  @override
  List<Object?> get props => [slots, message];
}

// Booking States
class CustomerBookingsLoaded extends CustomerState {
  final List<Booking> bookings;

  const CustomerBookingsLoaded(this.bookings, {String? message})
    : super(message: message);

  @override
  List<Object?> get props => [bookings, message];
}
