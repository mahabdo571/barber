import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/business.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/business_repository.dart';

part 'business_state.dart';

class BusinessCubit extends Cubit<BusinessState> {
  final BusinessRepository _repository;

  BusinessCubit(this._repository) : super(BusinessInitial());

  // Business Profile Methods
  Future<void> createBusiness(Business business) async {
    try {
      emit(BusinessLoading());
      final createdBusiness = await _repository.createBusiness(business);
      emit(BusinessProfileCreated(createdBusiness));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> updateBusiness(Business business) async {
    try {
      emit(BusinessLoading());
      final updatedBusiness = await _repository.updateBusiness(business);
      emit(BusinessProfileUpdated(updatedBusiness));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> loadBusiness(String id) async {
    try {
      emit(BusinessLoading());
      final business = await _repository.getBusiness(id);
      emit(BusinessProfileLoaded(business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> loadBusinessByOwnerId(String ownerId) async {
    try {
      emit(BusinessLoading());
      final business = await _repository.getBusinessByOwnerId(ownerId);
      emit(BusinessProfileLoaded(business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> updateBusinessStatus(String id, bool isActive) async {
    try {
      emit(BusinessLoading());
      await _repository.updateBusinessStatus(id, isActive);
      final business = await _repository.getBusiness(id);
      emit(BusinessProfileUpdated(business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  // Services Methods
  Future<void> createService(Service service) async {
    try {
      emit(BusinessLoading());
      final createdService = await _repository.createService(service);
      final services = await _repository.getBusinessServices(
        service.businessId,
      );
      final business = await _repository.getBusiness(service.businessId);
      emit(BusinessServicesLoaded(services, business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> updateService(Service service) async {
    try {
      emit(BusinessLoading());
      await _repository.updateService(service);
      final services = await _repository.getBusinessServices(
        service.businessId,
      );
      final business = await _repository.getBusiness(service.businessId);
      emit(BusinessServicesLoaded(services, business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> deleteService(String id, String businessId) async {
    try {
      emit(BusinessLoading());
      await _repository.deleteService(id);
      final services = await _repository.getBusinessServices(businessId);
      final business = await _repository.getBusiness(businessId);
      emit(BusinessServicesLoaded(services, business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> loadBusinessServices(String businessId) async {
    try {
      print('Loading services for business: $businessId'); // Debug log
      emit(BusinessLoading());
      final services = await _repository.getBusinessServices(businessId);
      final business = await _repository.getBusiness(businessId);
      print('Services loaded successfully: ${services.length}'); // Debug log
      emit(BusinessServicesLoaded(services, business));
    } catch (e) {
      print('Error loading services: $e'); // Debug log
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> updateServiceStatus(
    String id,
    bool isActive,
    String businessId,
  ) async {
    try {
      emit(BusinessLoading());
      await _repository.updateServiceStatus(id, isActive);
      final services = await _repository.getBusinessServices(businessId);
      final business = await _repository.getBusiness(businessId);
      emit(BusinessServicesLoaded(services, business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  // Time Slots Methods
  Future<void> generateTimeSlots({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime startTime,
    required DateTime endTime,
    required int intervalMinutes,
  }) async {
    try {
      emit(BusinessLoading());
      final slots = await _repository.generateTimeSlots(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        intervalMinutes: intervalMinutes,
      );
      final business = await _repository.getBusiness(businessId);
      emit(BusinessTimeSlotsLoaded(slots, business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> loadAvailableTimeSlots(String businessId, DateTime date) async {
    try {
      emit(BusinessLoading());
      final slots = await _repository.getAvailableTimeSlots(businessId, date);
      final business = await _repository.getBusiness(businessId);
      emit(BusinessTimeSlotsLoaded(slots, business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> loadBookedTimeSlots(String businessId, DateTime date) async {
    try {
      emit(BusinessLoading());
      final slots = await _repository.getBookedTimeSlots(businessId, date);
      final business = await _repository.getBusiness(businessId);
      emit(BusinessTimeSlotsLoaded(slots, business));
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> updateTimeSlotStatus(
    String id,
    bool isBooked,
    String? bookingId,
  ) async {
    try {
      emit(BusinessLoading());
      await _repository.updateTimeSlotStatus(id, isBooked, bookingId);
      emit(BusinessTimeSlotUpdated());
    } catch (e) {
      emit(BusinessError(e.toString()));
    }
  }

  Future<void> deleteTimeSlot(
    String id,
    String businessId,
    DateTime date,
  ) async {
    try {
      emit(BusinessLoading());
      await _repository.deleteTimeSlot(id);

      // تحديث القائمة بعد الحذف
      await _reloadTimeSlots(businessId);
    } catch (e) {
      print('Error in deleteTimeSlot: $e');
      emit(BusinessError('فشل في حذف الموعد'));
    }
  }

  Future<void> deleteTimeSlotsByDate(String businessId, DateTime date) async {
    try {
      emit(BusinessLoading());

      print('Starting deletion process for date: ${date.toString()}');

      // حذف المواعيد
      await _repository.deleteTimeSlotsByDate(businessId, date);

      // تأخير قصير للتأكد من اكتمال عملية الحذف
      await Future.delayed(const Duration(milliseconds: 500));

      // إعادة تحميل المواعيد المتاحة
      final slots = await _repository.getAvailableTimeSlots(
        businessId,
        DateTime.now(),
      );
      final business = await _repository.getBusiness(businessId);

      print('Reloaded ${slots.length} available slots after deletion');

      emit(BusinessTimeSlotsLoaded(slots, business));
    } catch (e) {
      print('Error in deleteTimeSlotsByDate: $e');
      emit(BusinessError('فشل في حذف المواعيد'));
    }
  }

  // دالة مساعدة لإعادة تحميل المواعيد
  Future<void> _reloadTimeSlots(String businessId) async {
    try {
      final slots = await _repository.getAvailableTimeSlots(
        businessId,
        DateTime.now(),
      );
      final business = await _repository.getBusiness(businessId);
      emit(BusinessTimeSlotsLoaded(slots, business));
    } catch (e) {
      print('Error in _reloadTimeSlots: $e');
      emit(BusinessError('فشل في تحديث المواعيد'));
    }
  }
}
