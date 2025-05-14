import '../entities/customer.dart';
import '../entities/booking.dart';

abstract class CustomerRepository {
  // Customer Profile
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<Customer> getCustomer(String id);
  Future<void> toggleFavoriteBusiness(String customerId, String businessId);

  // Bookings
  Future<Booking> createBooking(Booking booking);
  Future<Booking> updateBooking(Booking booking);
  Future<List<Booking>> getCustomerBookings(String customerId);
  Future<List<Booking>> getCustomerUpcomingBookings(String customerId);
  Future<void> cancelBooking(String bookingId);
}
