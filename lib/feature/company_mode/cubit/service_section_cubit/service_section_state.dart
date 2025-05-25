part of 'service_section_cubit.dart';

abstract class ServiceSectionState {
  const ServiceSectionState();
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceSectionState {}

class ServiceLoading extends ServiceSectionState {}

class ServiceSuccess extends ServiceSectionState {
  final String message;
  final List<ServiceModel> services;
  const ServiceSuccess({required this.services, required this.message});
  @override
  List<Object?> get props => [message];
}

class ServiceFailure extends ServiceSectionState {
  final String error;
  const ServiceFailure({required this.error});
  @override
  List<Object?> get props => [error];
}

class ServiceLoaded extends ServiceSectionState {
  final ServiceModel service;
  const ServiceLoaded(this.service);
  @override
  List<Object?> get props => [service];
}

class ServiceListLoaded extends ServiceSectionState {
  final List<ServiceModel> services;
  const ServiceListLoaded(this.services);
  @override
  List<Object?> get props => [services];
}
