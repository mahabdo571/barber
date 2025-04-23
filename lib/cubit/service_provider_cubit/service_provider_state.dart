part of 'service_provider_cubit.dart';




/// State Management: حالات الكيوبت
enum ServiceStatus { initial, loading, success, failure }

class ServiceProviderState extends Equatable {
  final ServiceStatus status;
  final List<Service> services;
  final String? errorMessage;

  const ServiceProviderState({
    this.status = ServiceStatus.initial,
    this.services = const [],
    this.errorMessage,
  });

  ServiceProviderState copyWith({
    ServiceStatus? status,
    List<Service>? services,
    String? errorMessage,
  }) {
    return ServiceProviderState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, services, errorMessage];
}