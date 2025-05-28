import 'package:barber/feature/company_mode/data/appointment/appointment_repository.dart';
import 'package:barber/feature/company_mode/models/appointment/appointment_date_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<AppointmentDateModel>> fetchDates(String userId) async {
    final query =
        await _firestore
            .collection('appointments')
            .where('createdBy', isEqualTo: userId)
            .get();
    return query.docs.map((doc) => AppointmentDateModel.fromDoc(doc)).toList();
  }

  @override
  Future<void> addDate(AppointmentDateModel date) async {
    await _firestore.collection('appointments').doc(date.id).set(date.toMap());
  }

  @override
  Future<void> deleteDate(String dateId) async {
    await _firestore.collection('appointments').doc(dateId).delete();
  }

  @override
  Future<void> toggleSlot(String dateId, String slotTime, bool isActive) async {
    final docRef = _firestore.collection('appointments').doc(dateId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final slots =
        (data['slots'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    for (var slot in slots) {
      if (slot['time'] == slotTime) {
        slot['isActive'] = isActive;
        break;
      }
    }

    await docRef.update({'slots': slots});
  }
}
