import 'package:barber/feature/company_mode/models/appointment/appointment_date_model.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentDateModel>> fetchDates(String userId);
  Future<void> addDate(AppointmentDateModel date);
  Future<void> deleteDate(String dateId);
  Future<void> toggleSlot(String dateId, String slotTime, bool isActive);
}
