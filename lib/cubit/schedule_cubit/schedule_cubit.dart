import '../../Repository/provider/schedule_repository.dart';
import 'schedule_state.dart';
import '../../models/schedule_model.dart';
import '../../models/time_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleCubit({required ScheduleRepository repository})
    : _repository = repository,
      super(const ScheduleState());

  /// جلب كل الجداول الزمنية
  Future<void> loadSchedules() async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final schedules = await _repository.fetchSchedules();
      emit(
        state.copyWith(status: ScheduleStatus.success, schedules: schedules),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// توليد جداول بين تاريخين
  Future<void> generateSchedules({
    required DateTime from,
    required DateTime to,
    required TimeOfDay start,
    required TimeOfDay end,
    required Duration interval,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _repository.generateSchedules(
        from: from,
        to: to,
        start: start,
        end: end,
        interval: interval,
      );
      await loadSchedules();
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// إضافة جدول يومي واحد
  Future<void> addSchedule(ScheduleModel schedule) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _repository.addSchedule(schedule);
      await loadSchedules();
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// تحديث TimeSlot محدد
  Future<void> updateTimeSlot({
    required String dateId,
    required TimeSlot slot,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _repository.updateTimeSlot(dateId: dateId, slot: slot);
      await loadSchedules();
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// حذف TimeSlot محدد
  Future<void> deleteTimeSlot({
    required String dateId,
    required String slotId,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _repository.deleteTimeSlot(dateId: dateId, slotId: slotId);
      await loadSchedules();
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// داخل class ScheduleCubit
  Future<void> deleteSchedule(String dateId) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _repository.deleteSchedule(dateId);
      final data = await _repository.fetchSchedules();
      await loadSchedules();
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
