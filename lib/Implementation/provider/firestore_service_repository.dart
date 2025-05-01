import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Repository/provider/service_repository.dart';
import '../../constants.dart';
import '../../models/service_model.dart';

/// Implementation: Firestore
class FirestoreServiceRepository implements ServiceRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  FirestoreServiceRepository({FirebaseFirestore? firestore, String? userId})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _userId = userId ?? FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _servicesColl =>
      _firestore.collection(kDBUser);

  @override
  Future<List<Service>> fetchServices(String providerID) async {
    final serves = _servicesColl.doc(providerID).collection('services');
    final snapshot = await serves.get();
    return snapshot.docs
        .map((doc) => Service.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addService(Service service) async {
    final serves = _servicesColl.doc(_userId).collection('services');

    await serves.add(service.toJson());
  }

  @override
  Future<void> updateService(Service service) async {
    final serves = _servicesColl.doc(_userId).collection('services');

    await serves.doc(service.id).update(service.toJson());
  }

  @override
  Future<void> deleteService(String serviceId) async {
    final serves = _servicesColl.doc(_userId).collection('services');

    await serves.doc(serviceId).delete();
  }
}
