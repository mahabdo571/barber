import '../../Repository/provider/service_repository.dart';
import '../../models/service_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'service_provider_state.dart';


/// Cubit: مسؤول عن الواجهة مع ال UI
class ServiceProviderCubit extends Cubit<ServiceProviderState> {
  final ServiceRepository _repository;

  ServiceProviderCubit({required ServiceRepository repository})
      : _repository = repository,
        super(const ServiceProviderState());

  /// جلب كل الخدمات
  Future<void> loadServices() async {
    emit(state.copyWith(status: ServiceStatus.loading));
    try {
      final services = await _repository.fetchServices();
      emit(state.copyWith(
        status: ServiceStatus.success,
        services: services,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServiceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// إضافة خدمة جديدة
  Future<void> addService(Service service) async {
    try {
      await _repository.addService(service);
      await loadServices();
    } catch (e) {
      emit(state.copyWith(
        status: ServiceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// تعديل خدمة
  Future<void> updateService(Service service) async {
    try {
      await _repository.updateService(service);
      await loadServices();
    } catch (e) {
      emit(state.copyWith(
        status: ServiceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// حذف خدمة
  Future<void> deleteService(String serviceId) async {
    try {
      await _repository.deleteService(serviceId);
      await loadServices();
    } catch (e) {
      emit(state.copyWith(
        status: ServiceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
