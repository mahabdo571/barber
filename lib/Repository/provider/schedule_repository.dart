import 'package:barber/models/schedule_model.dart';
import 'package:barber/models/time_slot.dart';
import 'package:flutter/material.dart';

abstract class ScheduleRepository {
  /// جلب كل الجداول الزمنية (اليومية) للمستخدم
  Future<List<ScheduleModel>> fetchSchedules();

  /// توليد جداول زمنية بين تاريخين مع الفاصل الزمني
  Future<void> generateSchedules({
    required DateTime from,
    required DateTime to,
    required TimeOfDay start,
    required TimeOfDay end,
    required Duration interval,
  });

  /// إضافة جدول يومي واحد
  Future<void> addSchedule(ScheduleModel schedule);

  /// تحديث TimeSlot محدد ضمن جدول يومي
  Future<void> updateTimeSlot({required String dateId, required TimeSlot slot});

  /// حذف TimeSlot محدد ضمن جدول يومي
  Future<void> deleteTimeSlot({required String dateId, required String slotId});

  /// حذف جدول يومي كامل
  Future<void> deleteSchedule(String dateId);
}
