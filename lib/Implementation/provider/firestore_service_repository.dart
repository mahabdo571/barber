import 'package:barber/Repository/provider/service_repository.dart';
import 'package:barber/constants.dart';
import 'package:barber/models/service_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Implementation: Firestore
class FirestoreServiceRepository implements ServiceRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirestoreServiceRepository({FirebaseFirestore? firestore, String? userId})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId ?? FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _servicesColl => _firestore
      .collection(kDBUser)
      .doc(_userId)
      .collection('services');

  @override
  Future<List<Service>> fetchServices() async {
    final snapshot = await _servicesColl.get();
    return snapshot.docs
        .map((doc) => Service.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addService(Service service) async {
    await _servicesColl.add(service.toJson());
  }

  @override
  Future<void> updateService(Service service) async {
    await _servicesColl.doc(service.id).update(service.toJson());
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await _servicesColl.doc(serviceId).delete();
  }
}