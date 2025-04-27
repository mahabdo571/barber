part of 'customers_cubit.dart';

enum CustomerStatus { initial, loading, success, failure }

class CustomersState extends Equatable {
  final CustomerStatus status;
  final CustomerModel? customer;
  final String? errorMessage;

  const CustomersState({
    this.status = CustomerStatus.initial,
    this.customer,
    this.errorMessage,
  });

  CustomersState copyWith({
    CustomerStatus? status,
    CustomerModel? customer,
    String? errorMessage,
  }) {
    return CustomersState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, customer, errorMessage];
}
