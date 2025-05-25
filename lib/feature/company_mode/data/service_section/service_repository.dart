import 'package:barber/feature/company_mode/models/service_model.dart';

abstract class ServiceRepository {
  Future<void> addService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String serviceId);
  Future<ServiceModel?> getServiceById(String serviceId);
  Future<List<ServiceModel>> getServicesByUser(String userId);
  Future<void> toggleServiceAvailability(String serviceId, bool status);
}
