import 'package:cloud_firestore/cloud_firestore.dart';
import 'time_slot_model.dart';

class AppointmentDateModel {
  final String id;
  final Timestamp date;
  final List<TimeSlotModel> slots;
  final String createdBy;

  AppointmentDateModel({
    required this.id,
    required this.date,
    required this.slots,
    required this.createdBy,
  });

  factory AppointmentDateModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final slotsList =
        (data['slots'] as List<dynamic>?)
            ?.map((slot) => TimeSlotModel.fromMap(slot))
            .toList() ??
        [];
    return AppointmentDateModel(
      id: doc.id,
      date: data['date'],
      slots: slotsList,
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toMap() => {
    'date': date,
    'slots': slots.map((e) => e.toMap()).toList(),
    'createdBy': createdBy,
  };
}
