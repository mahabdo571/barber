import '../entities/business.dart';
import '../entities/service.dart';
import '../entities/time_slot.dart';

abstract class BusinessRepository {
  // Business Profile
  Future<Business> createBusiness(Business business);
  Future<Business> updateBusiness(Business business);
  Future<Business> getBusiness(String id);
  Future<Business> getBusinessByOwnerId(String ownerId);
  Future<void> updateBusinessStatus(String id, bool isActive);

  // Services
  Future<Service> createService(Service service);
  Future<Service> updateService(Service service);
  Future<void> deleteService(String id);
  Future<List<Service>> getBusinessServices(String businessId);
  Future<void> updateServiceStatus(String id, bool isActive);

  // Time Slots
  Future<List<TimeSlot>> generateTimeSlots({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime startTime,
    required DateTime endTime,
    required int intervalMinutes,
  });
  Future<List<TimeSlot>> getAvailableTimeSlots(
    String businessId,
    DateTime date,
  );
  Future<List<TimeSlot>> getBookedTimeSlots(String businessId, DateTime date);
  Future<void> updateTimeSlotStatus(
    String id,
    bool isBooked,
    String? bookingId,
  );
}
