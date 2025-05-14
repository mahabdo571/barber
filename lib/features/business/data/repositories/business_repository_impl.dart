import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  @override
  Future<Business> createBusiness(Business business) async {
    final businessDoc = _firestore.collection(AppConstants.colBusinesses).doc();
    final businessWithId = business.copyWith(
      id: businessDoc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await businessDoc.set(businessWithId.toMap());
    return businessWithId;
  }

  @override
  Future<Business> updateBusiness(Business business) async {
    final businessWithTimestamp = business.copyWith(updatedAt: DateTime.now());
    await _firestore
        .collection(AppConstants.colBusinesses)
        .doc(business.id)
        .update(businessWithTimestamp.toMap());
    return businessWithTimestamp;
  }

  @override
  Future<Business> getBusiness(String id) async {
    final doc =
        await _firestore.collection(AppConstants.colBusinesses).doc(id).get();
    if (!doc.exists) {
      throw Exception('Business not found');
    }
    return Business.fromMap(doc.data()!..['id'] = doc.id);
  }

  @override
  Future<Business> getBusinessByOwnerId(String ownerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(AppConstants.colBusinesses)
              .where('ownerId', isEqualTo: ownerId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception(
          'No business profile found. Please complete your business profile setup.',
        );
      }

      final doc = querySnapshot.docs.first;
      return Business.fromMap(doc.data()..['id'] = doc.id);
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Failed to load business profile: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateBusinessStatus(String id, bool isActive) async {
    await _firestore.collection(AppConstants.colBusinesses).doc(id).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<Service> createService(Service service) async {
    final serviceDoc = _firestore.collection(AppConstants.colServices).doc();
    final serviceWithId = service.copyWith(
      id: serviceDoc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await serviceDoc.set(serviceWithId.toMap());
    return serviceWithId;
  }

  @override
  Future<Service> updateService(Service service) async {
    final serviceWithTimestamp = service.copyWith(updatedAt: DateTime.now());
    await _firestore
        .collection(AppConstants.colServices)
        .doc(service.id)
        .update(serviceWithTimestamp.toMap());
    return serviceWithTimestamp;
  }

  @override
  Future<void> deleteService(String id) async {
    await _firestore.collection(AppConstants.colServices).doc(id).delete();
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
  Future<void> updateServiceStatus(String id, bool isActive) async {
    await _firestore.collection(AppConstants.colServices).doc(id).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<TimeSlot>> generateTimeSlots({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime startTime,
    required DateTime endTime,
    required int intervalMinutes,
  }) async {
    final slots = <TimeSlot>[];
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (
      var date = startDate;
      date.isBefore(endDate.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))
    ) {
      var currentTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      final endTimeOfDay = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      while (currentTime.isBefore(endTimeOfDay)) {
        final slotEndTime = currentTime.add(Duration(minutes: intervalMinutes));
        if (slotEndTime.isAfter(endTimeOfDay)) break;

        final slot = TimeSlot(
          id: _uuid.v4(),
          businessId: businessId,
          startTime: currentTime,
          endTime: slotEndTime,
          isBooked: false,
          createdAt: now,
          updatedAt: now,
        );

        final doc = _firestore.collection('timeSlots').doc(slot.id);
        batch.set(doc, slot.toMap());
        slots.add(slot);

        currentTime = slotEndTime;
      }
    }

    await batch.commit();
    return slots;
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(
    String businessId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot =
        await _firestore
            .collection('timeSlots')
            .where('businessId', isEqualTo: businessId)
            .where(
              'startTime',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
            )
            .where('startTime', isLessThan: endOfDay.toIso8601String())
            .where('isBooked', isEqualTo: false)
            .get();

    return querySnapshot.docs
        .map((doc) => TimeSlot.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<List<TimeSlot>> getBookedTimeSlots(
    String businessId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot =
        await _firestore
            .collection('timeSlots')
            .where('businessId', isEqualTo: businessId)
            .where(
              'startTime',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
            )
            .where('startTime', isLessThan: endOfDay.toIso8601String())
            .where('isBooked', isEqualTo: true)
            .get();

    return querySnapshot.docs
        .map((doc) => TimeSlot.fromMap(doc.data()..['id'] = doc.id))
        .toList();
  }

  @override
  Future<void> updateTimeSlotStatus(
    String id,
    bool isBooked,
    String? bookingId,
  ) async {
    await _firestore.collection('timeSlots').doc(id).update({
      'isBooked': isBooked,
      'bookingId': bookingId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
