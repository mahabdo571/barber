import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/customer_repository.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;

  CustomerCubit(this._repository) : super(CustomerInitial());

  Future<void> createCustomer(Customer customer) async {
    try {
      emit(CustomerLoading());
      final createdCustomer = await _repository.createCustomer(customer);
      emit(CustomerProfileCreated(createdCustomer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      emit(CustomerLoading());
      final updatedCustomer = await _repository.updateCustomer(customer);
      emit(CustomerProfileUpdated(updatedCustomer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadCustomer(String id) async {
    try {
      emit(CustomerLoading());
      final customer = await _repository.getCustomer(id);
      emit(CustomerProfileLoaded(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> toggleFavoriteBusiness(
    String customerId,
    String businessId,
  ) async {
    try {
      emit(CustomerLoading());
      await _repository.toggleFavoriteBusiness(customerId, businessId);
      final customer = await _repository.getCustomer(customerId);
      emit(CustomerProfileUpdated(customer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> createBooking(Booking booking) async {
    try {
      emit(CustomerLoading());
      final createdBooking = await _repository.createBooking(booking);
      final bookings = await _repository.getCustomerUpcomingBookings(
        booking.customerId,
      );
      emit(CustomerBookingsLoaded(bookings));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadCustomerBookings(String customerId) async {
    try {
      emit(CustomerLoading());
      final bookings = await _repository.getCustomerBookings(customerId);
      emit(CustomerBookingsLoaded(bookings));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadUpcomingBookings(String customerId) async {
    try {
      emit(CustomerLoading());
      final bookings = await _repository.getCustomerUpcomingBookings(
        customerId,
      );
      emit(CustomerBookingsLoaded(bookings));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> cancelBooking(String bookingId, String customerId) async {
    try {
      emit(CustomerLoading());
      await _repository.cancelBooking(bookingId);
      final bookings = await _repository.getCustomerUpcomingBookings(
        customerId,
      );
      emit(CustomerBookingsLoaded(bookings));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
