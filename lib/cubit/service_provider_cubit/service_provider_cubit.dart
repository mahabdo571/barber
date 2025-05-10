import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import 'package:get_it/get_it.dart';

import '../../Repository/provider/service_repository.dart';
import '../../models/service_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'service_provider_state.dart';

/// Cubit: مسؤول عن الواجهة مع ال UI
class ServiceProviderCubit extends Cubit<ServiceProviderState> {
  final ServiceRepository _repository;
  final _authCubit = GetIt.I<AuthCubit>();
  late String _userId;

  ServiceProviderCubit({required ServiceRepository repository})
    : _repository = repository,
      super(const ServiceProviderState()) {
    // جلب الحالة من AuthCubit
    final authState = _authCubit.state;
    if (authState is Authenticated) {
      // بعد التأكد من النوع نعمل cast
      _userId = authState.authUser!.uid;
    } else {
      _userId = '';
    }

    // لو حابب تحدث _userId إذا تغيّرت حالة الـ AuthCubit لاحقاً
    _authCubit.stream.listen((s) {
      if (s is Authenticated) {
        _userId = s.authUser!.uid;
        // مثلاً تطلق إيفنت لتحديث الـ UI أو تجيب بيانات جديدة:
        // fetchDataForUser(_userId);
        loadServices(_userId);
      }
    });
  }

  /// جلب كل الخدمات
  Future<void> loadServices(String providerId) async {
    emit(state.copyWith(status: ServiceStatus.loading));
    final services;
    try {
      if(providerId != _userId){
       services = await _repository.fetchServices(providerId);

      }else{
         services = await _repository.fetchServices(_userId);

      }
      emit(state.copyWith(status: ServiceStatus.success, services: services));
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// إضافة خدمة جديدة
  Future<void> addService(Service service) async {
    try {
      await _repository.addService(service);
      await loadServices(_userId);
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// تعديل خدمة
  Future<void> updateService(Service service) async {
    try {
      await _repository.updateService(service);
      await loadServices(_userId);
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// حذف خدمة
  Future<void> deleteService(String serviceId) async {
    try {
      await _repository.deleteService(serviceId);
      await loadServices(_userId);
    } catch (e) {
      emit(
        state.copyWith(
          status: ServiceStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
