import '../../Repository/provider/provider_pepository.dart';
import '../../constants.dart';
import '../../models/provider_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore implementation of ProviderRepository
class FirestoreProviderRepository implements ProviderRepository {
  final FirebaseFirestore _firestore;
  FirestoreProviderRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection(kDBUser);

  @override
  Future<ProviderModel?> searchProviderByPhone(String phone) async {
    final snapshot =
        await _usersRef
            .where('role', isEqualTo: 'provider')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return ProviderModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<void> addProviderToFavorites({
    required String customerId,
    required ProviderModel provider,
  }) async {
    await _usersRef
        .doc(customerId)
        .collection('favorites')
        .doc(provider.uid)
        .set({
          'name': provider.name,
          'uid': provider.uid,
          'phone': provider.phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<bool> isProviderInFavorite({
    required String customerId,
    required String providerId,
  }) async {
    try {
      final favDoc =
          await _usersRef
              .doc(customerId)
              .collection('favorites')
              .doc(providerId)
              .get();
      return favDoc.exists;
    } catch (e) {
      return false;
    }
  }
}
