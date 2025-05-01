import '../../models/service_model.dart';

abstract class ServiceRepository {
  Future<List<Service>> fetchServices(String providerId);
  Future<void> addService(Service service);
  Future<void> updateService(Service service);
  Future<void> deleteService(String serviceId);
}
