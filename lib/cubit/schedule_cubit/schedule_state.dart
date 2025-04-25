import '../../models/schedule_model.dart';
import 'package:equatable/equatable.dart';

/// حالات الكيوبت
enum ScheduleStatus { initial, loading, success, failure }

/// الحالة الحالية للجداول الزمنية
class ScheduleState extends Equatable {
  final ScheduleStatus status;
  final List<ScheduleModel> schedules;
  final String? errorMessage;

  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.schedules = const [],
    this.errorMessage,
  });

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<ScheduleModel>? schedules,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, schedules, errorMessage];
}
