
import 'package:barber/models/time_slot.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleModel extends Equatable {
  final String date; // بصيغة 'yyyy-MM-dd'
  final List<TimeSlot> slots;

  const ScheduleModel({
    required this.date,
    this.slots = const [],
  });

  /// إنشاء نسخة معدلة
  ScheduleModel copyWith({
    String? date,
    List<TimeSlot>? slots,
  }) {
    return ScheduleModel(
      date: date ?? this.date,
      slots: slots ?? this.slots,
    );
  }

  /// من JSON(read)
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final List<TimeSlot> slots = [];
    if (json['timeSlots'] is Map<String, dynamic>) {
      (json['timeSlots'] as Map<String, dynamic>).forEach((key, value) {
        slots.add(TimeSlot.fromJson(value as Map<String, dynamic>, key));
      });
    }
    return ScheduleModel(
      date: json['date'] as String,
      slots: slots,
    );
  }

  /// إلى JSON(write)
  Map<String, dynamic> toJson() => {
        'date': date,
        'timeSlots': {
          for (var slot in slots) slot.id: slot.toJson(),
        },
      };

  @override
  List<Object?> get props => [date, slots];

  /// توليد TimeSlots لفترة واحدة
  static List<TimeSlot> generateSlots({
    required DateTime date,
    required TimeOfDay start,
    required TimeOfDay end,
    required Duration interval,
  }) {
    final List<TimeSlot> result = [];
    // ابدأ من بداية الدوام
    DateTime slot = DateTime(
      date.year,
      date.month,
      date.day,
      start.hour,
      start.minute,
    );
    // نهاية الدوام
    final DateTime endAt = DateTime(
      date.year,
      date.month,
      date.day,
      end.hour,
      end.minute,
    );
    // مولّد معرف عشوائي
    String generateId() => DateTime.now().microsecondsSinceEpoch.toString();
    // فورمات الوقت
    final formatter = DateFormat('HH:mm');

    while (!slot.isAfter(endAt)) {
      result.add(TimeSlot(
        id: generateId(),
        time: formatter.format(slot),
      ));
      slot = slot.add(interval);
    }
    return result;
  }

  /// توليد جداول أيام بين تاريخين
  static List<ScheduleModel> generateSchedules({
    required DateTime from,
    required DateTime to,
    required TimeOfDay start,
    required TimeOfDay end,
    required Duration interval,
  }) {
    final List<ScheduleModel> days = [];
    for (var day = from;
        !day.isAfter(to);
        day = day.add(const Duration(days: 1))) {
      final String dateId = DateFormat('yyyy-MM-dd').format(day);
      final slots = generateSlots(
        date: day,
        start: start,
        end: end,
        interval: interval,
      );
      days.add(ScheduleModel(date: dateId, slots: slots));
    }
    return days;
  }
}
