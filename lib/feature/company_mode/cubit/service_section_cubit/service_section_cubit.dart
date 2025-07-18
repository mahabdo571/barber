import 'package:barber/feature/auth/data/auth_repo.dart';
import 'package:barber/feature/users/models/user_model.dart';
import 'package:barber/feature/company_mode/data/service_section/service_repository.dart';
import 'package:barber/feature/company_mode/models/service_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'service_section_state.dart';

class ServiceSectionCubit extends Cubit<ServiceSectionState> {
  final ServiceRepository _repository;
  final AuthRepo _authRepo;

  ServiceSectionCubit(this._repository, this._authRepo)
    : super(ServiceInitial());

  Future<void> addService(ServiceModel service) async {
    emit(ServiceLoading());
    try {
      await _repository.addService(service);
      UserModel? user = await _authRepo.getCurrentUser();
      final services = await _repository.getServicesByUser(user!.uid);

      emit(
        ServiceSuccess(services: services, message: 'تمت إضافة الخدمة بنجاح'),
      );
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }

  Future<void> updateService(ServiceModel service) async {
    emit(ServiceLoading());
    try {
      await _repository.updateService(service);
      UserModel? user = await _authRepo.getCurrentUser();
      final services = await _repository.getServicesByUser(user!.uid);

      emit(ServiceSuccess(services: services, message: 'تم تعديل الخدمة'));
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }

  Future<void> deleteService(String serviceId) async {
    emit(ServiceLoading());
    try {
      await _repository.deleteService(serviceId);
      UserModel? user = await _authRepo.getCurrentUser();

      final services = await _repository.getServicesByUser(user!.uid);
      emit(ServiceSuccess(services: services, message: 'تم حذف الخدمة'));
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }

  Future<void> getServiceById(String serviceId) async {
    emit(ServiceLoading());
    try {
      final service = await _repository.getServiceById(serviceId);
      if (service != null) {
        emit(ServiceLoaded(service));
      } else {
        emit(ServiceFailure(error: 'الخدمة غير موجودة'));
      }
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }

  Future<void> getServicesByUser(String userId) async {
    emit(ServiceLoading());
    userId = userId;
    try {
      final services = await _repository.getServicesByUser(userId);

      emit(ServiceListLoaded(services));
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }

  Future<void> toggleServiceAvailability(String serviceId, bool status) async {
    emit(ServiceLoading());
    try {
      await _repository.toggleServiceAvailability(serviceId, status);
      final services = await _repository.getServicesByUser(
        '5cDtwlG6F9VYGTy65ctIK2WhTq93',
      );

      emit(
        ServiceSuccess(
          services: services,
          message: status ? 'تم تفعيل الخدمة' : 'تم تعطيل الخدمة',
        ),
      );
    } catch (e) {
      emit(ServiceFailure(error: e.toString()));
    }
  }
}
