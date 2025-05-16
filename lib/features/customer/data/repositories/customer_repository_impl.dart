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
    // Get the booking to identify the associated time slot
    final bookingDoc =
        await _firestore
            .collection(AppConstants.colBookings)
            .doc(bookingId)
            .get();
    if (!bookingDoc.exists) {
      throw Exception('Booking not found');
    }

    final bookingData = bookingDoc.data()!;
    final timeSlotId = bookingData['timeSlotId'] as String;

    // Use a transaction to ensure both updates happen atomically
    await _firestore.runTransaction((transaction) async {
      // 1. Update booking status to cancelled
      transaction.update(
        _firestore.collection(AppConstants.colBookings).doc(bookingId),
        {'status': 'cancelled', 'updatedAt': DateTime.now().toIso8601String()},
      );

      // 2. Release the time slot
      transaction.update(
        _firestore.collection(AppConstants.colTimeSlots).doc(timeSlotId),
        {
          'isBooked': false,
          'bookingId': null,
          'bookedBy': null,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Stream<List<Booking>> streamCustomerBookings(String customerId) {
    return _firestore
        .collection(AppConstants.colBookings)
        .where('customerId', isEqualTo: customerId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()..['id'] = doc.id))
              .toList();
        });
  }

  @override
  Stream<List<Booking>> streamCustomerUpcomingBookings(String customerId) {
    final now = DateTime.now();
    return _firestore
        .collection(AppConstants.colBookings)
        .where('customerId', isEqualTo: customerId)
        .where('startTime', isGreaterThanOrEqualTo: now.toIso8601String())
        .where('status', whereIn: ['pending', 'confirmed'])
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromMap(doc.data()..['id'] = doc.id))
              .toList();
        });
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
      throw Exception('Business not found');
    }
    return Business.fromMap(doc.data()!..['id'] = doc.id);
  }

  @override
  Future<List<Service>> getBusinessServices(String businessId) async {
    final querySnapshot =
        await _firestore
            .collection(AppConstants.colServices)
            .where('businessId', isEqualTo: businessId)
            .orderBy('createdAt', descending: true)
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

  @override
  Future<Booking> updateBookingNotes(String bookingId, String notes) async {
    final now = DateTime.now();
    await _firestore.collection(AppConstants.colBookings).doc(bookingId).update(
      {'notes': notes, 'updatedAt': now.toIso8601String()},
    );

    final doc =
        await _firestore
            .collection(AppConstants.colBookings)
            .doc(bookingId)
            .get();
    return Booking.fromMap(doc.data()!..['id'] = doc.id);
  }

  @override
  Future<void> cleanupPastBookings(String customerId) async {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    // Get bookings that have ended at least 24 hours ago and are still in pending/confirmed state
    final querySnapshot =
        await _firestore
            .collection(AppConstants.colBookings)
            .where('customerId', isEqualTo: customerId)
            .where('endTime', isLessThan: twentyFourHoursAgo.toIso8601String())
            .where('status', whereIn: ['pending', 'confirmed'])
            .get();

    if (querySnapshot.docs.isEmpty) return;

    // Use a batch to update all these bookings efficiently
    final batch = _firestore.batch();

    for (final doc in querySnapshot.docs) {
      batch.update(
        _firestore.collection(AppConstants.colBookings).doc(doc.id),
        {'status': 'completed', 'updatedAt': now.toIso8601String()},
      );
    }

    await batch.commit();
  }
}
