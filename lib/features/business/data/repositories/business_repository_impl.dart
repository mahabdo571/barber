import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/booking.dart';
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
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
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
          if (e.code == 'failed-precondition' || e.code == 'unavailable') {
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(retryDelay);
              continue;
            }
          }
          throw Exception('Failed to load business profile: ${e.message}');
        }
        rethrow;
      }
    }
    throw Exception('Failed to load business profile after multiple attempts');
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
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        print('Attempt ${retryCount + 1} to load services'); // Debug log
        final querySnapshot =
            await _firestore
                .collection(AppConstants.colServices)
                .where('businessId', isEqualTo: businessId)
                .get();

        print(
          'Query successful, documents: ${querySnapshot.docs.length}',
        ); // Debug log

        final services =
            querySnapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              print('Processing document: ${doc.id}'); // Debug log
              return Service.fromMap(data);
            }).toList();

        // Sort services by createdAt locally instead of in the query
        services.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        print('Services processed successfully'); // Debug log
        return services;
      } catch (e) {
        print('Error in attempt ${retryCount + 1}: $e'); // Debug log
        if (e is FirebaseException) {
          print('Firebase error code: ${e.code}'); // Debug log
          if (e.code == 'failed-precondition' || e.code == 'unavailable') {
            retryCount++;
            if (retryCount < maxRetries) {
              print('Retrying after delay...'); // Debug log
              await Future.delayed(retryDelay);
              continue;
            }
          }
          throw Exception('Failed to load services: ${e.message}');
        }
        rethrow;
      }
    }
    print('All retries failed'); // Debug log
    return []; // Return empty list if all retries failed
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

        final doc = _firestore
            .collection(AppConstants.colTimeSlots)
            .doc(slot.id);
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
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(
        const Duration(days: 30),
      ); // نجلب مواعيد 30 يوم

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

      print('Found ${querySnapshot.docs.length} available slots');

      return querySnapshot.docs
          .map((doc) => TimeSlot.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error in getAvailableTimeSlots: $e');
      rethrow;
    }
  }

  @override
  Future<List<TimeSlot>> getBookedTimeSlots(
    String businessId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      print('Fetching booked slots for date: ${date.toString()}');

      // جلب المواعيد المحجوزة فقط
      final querySnapshot =
          await _firestore
              .collection(AppConstants.colTimeSlots)
              .where('businessId', isEqualTo: businessId)
              .where('isBooked', isEqualTo: true)
              .where(
                'startTime',
                isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
              )
              .where('startTime', isLessThan: endOfDay.toIso8601String())
              .orderBy('startTime')
              .get();

      print('Found ${querySnapshot.docs.length} booked slots');

      final slots = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final timeSlot = TimeSlot.fromMap({...doc.data(), 'id': doc.id});

          if (timeSlot.bookingId != null) {
            try {
              // جلب معلومات الحجز
              final bookingDoc =
                  await _firestore
                      .collection(AppConstants.colBookings)
                      .doc(timeSlot.bookingId)
                      .get();

              if (bookingDoc.exists) {
                final bookingData = bookingDoc.data()!;
                bookingData['id'] = bookingDoc.id;
                final booking = Booking.fromMap(bookingData);

                // جلب معلومات المستخدم
                final userDoc =
                    await _firestore
                        .collection(AppConstants.colUsers)
                        .doc(booking.customerId)
                        .get();

                // جلب معلومات الخدمة
                final serviceDoc =
                    await _firestore
                        .collection(AppConstants.colServices)
                        .doc(booking.serviceId)
                        .get();

                final userData = userDoc.data();
                final serviceData = serviceDoc.data();

                return timeSlot.copyWith(
                  customerName: userData?['name'] as String? ?? 'غير معروف',
                  serviceName: serviceData?['name'] as String? ?? 'غير معروف',
                  notes: booking.notes,
                );
              }
            } catch (e) {
              print('Error fetching booking details: $e');
            }
          }
          return timeSlot;
        }),
      );

      // فلترة المواعيد التي لديها معلومات العميل فقط
      return slots.where((slot) => slot.customerName != null).toList();
    } catch (e) {
      print('Error in getBookedTimeSlots: $e');
      return [];
    }
  }

  @override
  Future<void> updateTimeSlotStatus(
    String id,
    bool isBooked,
    String? bookingId,
  ) async {
    await _firestore.collection(AppConstants.colTimeSlots).doc(id).update({
      'isBooked': isBooked,
      'bookingId': bookingId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteTimeSlot(String id) async {
    try {
      await _firestore.collection(AppConstants.colTimeSlots).doc(id).delete();
    } catch (e) {
      print('Error deleting time slot: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTimeSlotsByDate(String businessId, DateTime date) async {
    try {
      // تحويل التاريخ إلى بداية ونهاية اليوم
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      print('Attempting to delete slots for date: ${date.toString()}');

      // تنفيذ الاستعلام بطريقة مختلفة
      final querySnapshot =
          await _firestore
              .collection(AppConstants.colTimeSlots)
              .where('businessId', isEqualTo: businessId)
              .get();

      // فلترة النتائج يدوياً للتاريخ المحدد
      final docsToDelete =
          querySnapshot.docs.where((doc) {
            final slotStartTime = DateTime.parse(
              doc.data()['startTime'] as String,
            );
            return slotStartTime.isAfter(
                  startOfDay.subtract(const Duration(seconds: 1)),
                ) &&
                slotStartTime.isBefore(
                  endOfDay.add(const Duration(seconds: 1)),
                );
          }).toList();

      print('Found ${docsToDelete.length} slots to delete');

      if (docsToDelete.isEmpty) {
        print('No slots found for the specified date');
        return;
      }

      // حذف المواعيد على دفعات للتعامل مع القيود
      const batchSize = 500; // Firestore يدعم حتى 500 عملية في الـ batch الواحد
      for (var i = 0; i < docsToDelete.length; i += batchSize) {
        final batch = _firestore.batch();
        final end =
            (i + batchSize < docsToDelete.length)
                ? i + batchSize
                : docsToDelete.length;

        for (var j = i; j < end; j++) {
          batch.delete(docsToDelete[j].reference);
        }

        await batch.commit();
        print('Deleted batch ${i ~/ batchSize + 1}');
      }

      print('Successfully deleted all slots for the date');
    } catch (e) {
      print('Error in deleteTimeSlotsByDate: $e');
      rethrow;
    }
  }
}
