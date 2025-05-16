import '../entities/customer.dart';
import '../entities/booking.dart';
import '../entities/business.dart';
import '../entities/service.dart';
import '../entities/time_slot.dart';

abstract class CustomerRepository {
  // Customer Profile
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<Customer> getCustomer(String id);

  // Favorites Management
  Future<bool> toggleFavoriteBusiness(String customerId, String businessId);
  Future<List<Business>> getFavoriteBusinesses(String customerId);

  // Business Search
  Future<Business> searchBusinessByPhone(String phone);
  Future<Business> getBusinessById(String businessId);
  Future<List<Service>> getBusinessServices(String businessId);
  Future<List<TimeSlot>> getBusinessAvailableTimeSlots(
    String businessId,
    DateTime date,
  );

  // Bookings
  Future<Booking> createBooking(Booking booking);
  Future<Booking> updateBooking(Booking booking);
  Future<List<Booking>> getCustomerBookings(String customerId);
  Future<List<Booking>> getCustomerUpcomingBookings(String customerId);
  Future<void> cancelBooking(String bookingId);
  Stream<List<Booking>> streamCustomerBookings(String customerId);
  Stream<List<Booking>> streamCustomerUpcomingBookings(String customerId);
  Future<Booking> updateBookingNotes(String bookingId, String notes);
  Future<void> cleanupPastBookings(String customerId);
}
