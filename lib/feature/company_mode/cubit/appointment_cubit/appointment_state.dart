part of 'appointment_cubit.dart';

@immutable
sealed class AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentDateModel> dates;
  AppointmentLoaded(this.dates);
}

class AppointmentError extends AppointmentState {
  final String message;
  AppointmentError(this.message);
}
