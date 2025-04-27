import 'package:barber/Repository/customers/customers_repository.dart';
import 'package:barber/models/customers_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'customers_state.dart';

/// Cubit: مسؤول عن الواجهة مع ال UI
class CustomersCubit extends Cubit<CustomersState> {
  final CustomersRepository _repository;

  CustomersCubit({required CustomersRepository repository})
    : _repository = repository,
      super(const CustomersState());

  Future<void> getCustomerById(String customerId) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    try {
      final customer = await _repository.getCustomerById(customerId);
      emit(state.copyWith(status: CustomerStatus.success, customer: customer));
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// إضافة خدمة جديدة
  Future<void> addCustomer(CustomerModel customer) async {
    try { 
      print('testm ${customer.name}');
      await _repository.addCustomer(customer);

    } catch (e) {
        print('testmc ${customer.name}');
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// تعديل خدمة
  Future<void> updateService(CustomerModel customer) async {
    try {
      await _repository.updateCustomer(customer);
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// حذف خدمة
  Future<void> deleteService(String customerId) async {
    try {
      await _repository.deleteCustomer(customerId);
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
