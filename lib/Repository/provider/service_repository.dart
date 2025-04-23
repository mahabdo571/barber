import 'package:barber/models/service_model.dart';

abstract class ServiceRepository {
  Future<List<Service>> fetchServices();
  Future<void> addService(Service service);
  Future<void> updateService(Service service);
  Future<void> deleteService(String serviceId);
}
