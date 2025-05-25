import 'package:barber/core/constants/app_collection.dart';
import 'package:barber/feature/company_mode/data/service_section/service_repository.dart';
import 'package:barber/feature/company_mode/models/service_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection(AppCollection.services);

  @override
  Future<void> addService(ServiceModel service) async {
    await _collection.doc(service.id).set(service.toMap());
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    await _collection.doc(service.id).update(service.toMap());
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await _collection.doc(serviceId).delete();
  }

  @override
  Future<ServiceModel?> getServiceById(String serviceId) async {
    final doc = await _collection.doc(serviceId).get();
    if (doc.exists) {
      return ServiceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  @override
  Future<List<ServiceModel>> getServicesByUser(String userId) async {
    final query = await _collection.where('userId', isEqualTo: userId).get();
    return query.docs
        .map(
          (doc) =>
              ServiceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  @override
  Future<void> toggleServiceAvailability(String serviceId, bool status) async {
    await _collection.doc(serviceId).update({'isAvailable': status});
  }
}
