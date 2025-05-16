import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/customer_repository.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;

  CustomerCubit(this._repository) : super(const CustomerInitial());

  Future<void> createCustomer(Customer customer) async {
    try {
      emit(const CustomerLoading());
      final createdCustomer = await _repository.createCustomer(customer);
      emit(CustomerProfileCreated(createdCustomer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      emit(const CustomerLoading());
      final updatedCustomer = await _repository.updateCustomer(customer);
      emit(CustomerProfileUpdated(updatedCustomer));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadCustomer(String id) async {
    try {
      emit(const CustomerLoading());
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
      emit(const CustomerLoading());
      final wasAdded = await _repository.toggleFavoriteBusiness(
        customerId,
        businessId,
      );

      // Load updated favorites list
      final businesses = await _repository.getFavoriteBusinesses(customerId);

      // Emit success state with message
      emit(
        CustomerFavoritesLoaded(
          businesses,
          message:
              wasAdded
                  ? 'Salon added to favorites.'
                  : 'Salon removed from favorites.',
        ),
      );
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadFavoriteBusinesses(String customerId) async {
    try {
      emit(const CustomerLoading());
      final businesses = await _repository.getFavoriteBusinesses(customerId);
      emit(CustomerFavoritesLoaded(businesses));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<Business> searchBusinessByPhone(String phone) async {
    try {
      return await _repository.searchBusinessByPhone(phone);
    } catch (e) {
      emit(CustomerError(e.toString()));
      rethrow;
    }
  }

  Future<void> loadBusinessDetails(String businessId) async {
    try {
      emit(const CustomerLoading());
      final business = await _repository.getBusinessById(businessId);
      final services = await _repository.getBusinessServices(businessId);
      emit(CustomerBusinessDetailsLoaded(business, services));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadBusinessTimeSlots(String businessId, DateTime date) async {
    try {
      emit(const CustomerLoading());
      final slots = await _repository.getBusinessAvailableTimeSlots(
        businessId,
        date,
      );

      if (slots.isEmpty) {
        emit(const CustomerError('No available time slots for this date.'));
        return;
      }

      emit(CustomerTimeSlotsLoaded(slots));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> createBooking(Booking booking) async {
    try {
      emit(const CustomerLoading());
      final createdBooking = await _repository.createBooking(booking);
      final bookings = await _repository.getCustomerUpcomingBookings(
        booking.customerId,
      );
      emit(
        CustomerBookingsLoaded(
          bookings,
          message: 'Booking created successfully.',
        ),
      );
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadCustomerBookings(String customerId) async {
    try {
      emit(const CustomerLoading());
      final bookings = await _repository.getCustomerBookings(customerId);
      emit(CustomerBookingsLoaded(bookings));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> loadUpcomingBookings(String customerId) async {
    try {
      emit(const CustomerLoading());
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
      emit(const CustomerLoading());
      await _repository.cancelBooking(bookingId);
      final bookings = await _repository.getCustomerUpcomingBookings(
        customerId,
      );
      emit(
        CustomerBookingsLoaded(
          bookings,
          message: 'Booking cancelled successfully.',
        ),
      );
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
