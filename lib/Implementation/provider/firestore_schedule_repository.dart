import '../../Repository/provider/schedule_repository.dart';
import '../../constants.dart';
import '../../models/schedule_model.dart';
import '../../models/time_slot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirestoreScheduleRepository implements ScheduleRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirestoreScheduleRepository({FirebaseFirestore? firestore, String? userId})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _userId = userId ?? FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _scheduleColl =>
      _firestore.collection(kDBUser).doc(_userId).collection('schedule');

  @override
  Future<List<ScheduleModel>> fetchSchedules() async {
    final dayDocs = await _scheduleColl.get();
    final schedules = <ScheduleModel>[];
    for (var doc in dayDocs.docs) {
      final slotDocs =
          await _scheduleColl.doc(doc.id).collection('timeSlots').get();
      final slots =
          slotDocs.docs.map((e) => TimeSlot.fromJson(e.data(), e.id)).toList();
      schedules.add(ScheduleModel(date: doc.id, slots: slots));
    }
    return schedules;
  }

  @override
  Future<void> generateSchedules({
    required DateTime from,
    required DateTime to,
    required TimeOfDay start,
    required TimeOfDay end,
    required Duration interval,
  }) async {
    final batch = _firestore.batch();
    final schedules = ScheduleModel.generateSchedules(
      from: from,
      to: to,
      start: start,
      end: end,
      interval: interval,
    );
    for (var day in schedules) {
      final dayDoc = _scheduleColl.doc(day.date);
      // حفظ توثيقة التاريخ الرئيسية
      batch.set(dayDoc, {'date': day.date});
      // حفظ TimeSlots في subcollection
      for (var slot in day.slots) {
        final slotDoc = dayDoc.collection('timeSlots').doc(slot.id);
        batch.set(slotDoc, slot.toJson());
      }
    }
    await batch.commit();
  }

  @override
  Future<void> addSchedule(ScheduleModel schedule) async {
    final dayDoc = _scheduleColl.doc(schedule.date);
    await dayDoc.set({'date': schedule.date});
    final slotColl = dayDoc.collection('timeSlots');
    final batch = _firestore.batch();
    for (var slot in schedule.slots) {
      final slotDoc = slotColl.doc(slot.id);
      batch.set(slotDoc, slot.toJson());
    }
    await batch.commit();
  }

  @override
  Future<void> updateTimeSlot({
    required String dateId,
    required TimeSlot slot,
  }) async {
    final slotDoc = _scheduleColl
        .doc(dateId)
        .collection('timeSlots')
        .doc(slot.id);
    await slotDoc.update(slot.toJson());
  }

  @override
  Future<void> deleteTimeSlot({
    required String dateId,
    required String slotId,
  }) async {
    final slotDoc = _scheduleColl
        .doc(dateId)
        .collection('timeSlots')
        .doc(slotId);
    await slotDoc.delete();
  }

  @override
  Future<void> deleteSchedule(String dateId) async {
    final dayDoc = _scheduleColl.doc(dateId);
    // احذف كل الـ TimeSlots أولاً
    final slotDocs = await dayDoc.collection('timeSlots').get();
    final batch = _firestore.batch();
    for (var doc in slotDocs.docs) {
      batch.delete(doc.reference);
    }
    // ثم احذف الوثيقة الرئيسية
    batch.delete(dayDoc);
    await batch.commit();
  }
}
