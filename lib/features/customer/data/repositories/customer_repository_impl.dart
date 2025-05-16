import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final customerDoc = _firestore
        .collection(AppConstants.colUsers)
        .doc(customer.id);
    final customerWithTimestamp = customer.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await customerDoc.set(customerWithTimestamp.toMap());
    return customerWithTimestamp;
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
  Future<bool> toggleFavoriteBusiness(
    String customerId,
    String businessId,
  ) async {
    final favoriteRef = _firestore
        .collection(AppConstants.colUsers)
        .doc(customerId)
        .collection('favorites')
        .doc(businessId);

    try {
      final favoriteDoc = await favoriteRef.get();

      if (favoriteDoc.exists) {
        // Remove from favorites
        await favoriteRef.delete();
        return false; // Indicates removal
      } else {
        // Add to favorites with timestamp
        await favoriteRef.set({
          'addedAt': DateTime.now().toIso8601String(),
          'businessId': businessId,
        });
        return true; // Indicates addition
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite status: ${e.toString()}');
    }
  }

  @override
  Future<List<Business>> getFavoriteBusinesses(String customerId) async {
    try {
      final favoritesSnapshot =
          await _firestore
              .collection(AppConstants.colUsers)
              .doc(customerId)
              .collection('favorites')
              .get();

      if (favoritesSnapshot.docs.isEmpty) return [];

      final businesses = await Future.wait(
        favoritesSnapshot.docs.map((doc) async {
          final businessDoc =
              await _firestore
                  .collection(AppConstants.colBusinesses)
                  .doc(doc.id)
                  .get();

          if (!businessDoc.exists) return null;
          return Business.fromMap(businessDoc.data()!..['id'] = businessDoc.id);
        }),
      );

      return businesses.whereType<Business>().toList();
    } catch (e) {
      throw Exception('Failed to load favorite businesses: ${e.toString()}');
    }
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

  @override
  Future<Business> searchBusinessByPhone(String phone) async {
    final querySnapshot =
        await _firestore
            .collection(AppConstants.colBusinesses)
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('لم يتم العثور على صالون بهذا الرقم');
    }

    final doc = querySnapshot.docs.first;
    return Business.fromMap(doc.data()..['id'] = doc.id);
  }

  @override
  Future<Business> getBusinessById(String businessId) async {
    final doc =
        await _firestore
            .collection(AppConstants.colBusinesses)
            .doc(businessId)
            .get();
    if (!doc.exists) {
      throw Exception('لم يتم العثور على الصالون');
    }
    return Business.fromMap(doc.data()!..['id'] = doc.id);
  }

  @override
  Future<List<Service>> getBusinessServices(String businessId) async {
    final querySnapshot =
        await _firestore
            .collection(AppConstants.colServices)
            .where('businessId', isEqualTo: businessId)
            .get();

    return querySnapshot.docs
        .map((doc) => Service.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<List<TimeSlot>> getBusinessAvailableTimeSlots(
    String businessId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot =
        await _firestore
            .collection(AppConstants.colTimeSlots)
            .where('businessId', isEqualTo: businessId)
            .where('isBooked', isEqualTo: false)
            .where(
              'startTime',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
            )
            .where('startTime', isLessThan: endOfDay.toIso8601String())
            .orderBy('startTime')
            .get();

    return querySnapshot.docs
        .map((doc) => TimeSlot.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }
}
