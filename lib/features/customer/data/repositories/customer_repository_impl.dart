import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final customerDoc = _firestore.collection(AppConstants.colUsers).doc();
    final customerWithId = customer.copyWith(
      id: customerDoc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await customerDoc.set(customerWithId.toMap());
    return customerWithId;
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final customerWithTimestamp = customer.copyWith(updatedAt: DateTime.now());
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(customer.id)
        .update(customerWithTimestamp.toMap());
    return customerWithTimestamp;
  }

  @override
  Future<Customer> getCustomer(String id) async {
    final doc =
        await _firestore.collection(AppConstants.colUsers).doc(id).get();
    if (!doc.exists) {
      throw Exception('Customer not found');
    }
    return Customer.fromMap(doc.data()!..['id'] = doc.id);
  }

  @override
  Future<void> toggleFavoriteBusiness(
    String customerId,
    String businessId,
  ) async {
    final customerDoc = _firestore
        .collection(AppConstants.colUsers)
        .doc(customerId);
    final customer = await getCustomer(customerId);

    final updatedFavorites = List<String>.from(customer.favoriteBusinessIds);
    if (updatedFavorites.contains(businessId)) {
      updatedFavorites.remove(businessId);
    } else {
      updatedFavorites.add(businessId);
    }

    await customerDoc.update({
      'favoriteBusinessIds': updatedFavorites,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    final bookingDoc = _firestore.collection(AppConstants.colBookings).doc();
    final bookingWithId = booking.copyWith(
      id: bookingDoc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await bookingDoc.set(bookingWithId.toMap());
    return bookingWithId;
  }

  @override
  Future<Booking> updateBooking(Booking booking) async {
    final bookingWithTimestamp = booking.copyWith(updatedAt: DateTime.now());
    await _firestore
        .collection(AppConstants.colBookings)
        .doc(booking.id)
        .update(bookingWithTimestamp.toMap());
    return bookingWithTimestamp;
  }

  @override
  Future<List<Booking>> getCustomerBookings(String customerId) async {
    final querySnapshot =
        await _firestore
            .collection(AppConstants.colBookings)
            .where('customerId', isEqualTo: customerId)
            .orderBy('startTime', descending: true)
            .get();

    return querySnapshot.docs
        .map((doc) => Booking.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<List<Booking>> getCustomerUpcomingBookings(String customerId) async {
    final now = DateTime.now();
    final querySnapshot =
        await _firestore
            .collection(AppConstants.colBookings)
            .where('customerId', isEqualTo: customerId)
            .where('startTime', isGreaterThanOrEqualTo: now.toIso8601String())
            .where('status', whereIn: ['pending', 'confirmed'])
            .orderBy('startTime')
            .get();

    return querySnapshot.docs
        .map((doc) => Booking.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection(AppConstants.colBookings).doc(bookingId).update(
      {'status': 'cancelled', 'updatedAt': DateTime.now().toIso8601String()},
    );
  }
}
