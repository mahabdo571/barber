import 'package:barber/feature/company_mode/data/appointment/appointment_repository.dart';
import 'package:barber/feature/company_mode/models/appointment/appointment_date_model.dart';
import 'package:barber/feature/company_mode/models/appointment/time_slot_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentCubit(this._repository) : super(AppointmentLoading());

  Future<void> loadAppointments(String userId) async {
    try {
      emit(AppointmentLoading());
      final dates = await _repository.fetchDates(userId);
      emit(AppointmentLoaded(dates));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> addAppointmentRange(
    DateTime start,
    DateTime end,
    TimeOfDay startTime,
    TimeOfDay endTime,
    int intervalMinutes,
    String userId,
  ) async {
    try {
      final dates = <AppointmentDateModel>[];
      for (
        var date = start;
        date.isBefore(end.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))
      ) {
        final id =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final slots = <TimeSlotModel>[];

        var time = DateTime(
          date.year,
          date.month,
          date.day,
          startTime.hour,
          startTime.minute,
        );
        final endTimeDate = DateTime(
          date.year,
          date.month,
          date.day,
          endTime.hour,
          endTime.minute,
        );

        while (time.isBefore(endTimeDate)) {
          slots.add(
            TimeSlotModel(
              time:
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              isActive: true,
              createdBy: userId,
            ),
          );
          time = time.add(Duration(minutes: intervalMinutes));
        }

        final appointment = AppointmentDateModel(
          id: id,
          date: Timestamp.fromDate(date),
          slots: slots,
          createdBy: userId,
        );

        await _repository.addDate(appointment);
        dates.add(appointment);
      }
      emit(AppointmentLoaded(dates));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> deleteAppointmentDate(String dateId) async {
    try {
      await _repository.deleteDate(dateId);
      if (state is AppointmentLoaded) {
        final current = (state as AppointmentLoaded).dates;
        emit(AppointmentLoaded(current.where((e) => e.id != dateId).toList()));
      }
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> toggleTimeSlot(String dateId, String slotTime) async {
    try {
      if (state is AppointmentLoaded) {
        final current = (state as AppointmentLoaded).dates;
        await _repository.toggleSlot(
          dateId,
          slotTime,
          !current
              .firstWhere((d) => d.id == dateId)
              .slots
              .firstWhere((s) => s.time == slotTime)
              .isActive,
        );

        final updatedDates =
            current.map((d) {
              if (d.id == dateId) {
                final updatedSlots =
                    d.slots.map((s) {
                      if (s.time == slotTime) {
                        return TimeSlotModel(
                          time: s.time,
                          isActive: !s.isActive,
                          createdBy: s.createdBy,
                        );
                      }
                      return s;
                    }).toList();
                return AppointmentDateModel(
                  id: d.id,
                  date: d.date,
                  slots: updatedSlots,
                  createdBy: d.createdBy,
                );
              }
              return d;
            }).toList();

        emit(AppointmentLoaded(updatedDates));
      }
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}
