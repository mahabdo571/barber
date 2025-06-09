
import 'package:barber/core/constants/app_collection.dart';
import 'package:barber/feature/users/data/user_repository.dart';
import 'package:barber/feature/users/models/store_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore firestore;

  UserRepositoryImpl(this.firestore);

    @override
  Future<List<String>> getFavoriteCompanyIds(String userId) async {
    final snapshot = await firestore.collection(AppCollection.users).doc(userId).get();
    final data = snapshot.data();
    return List<String>.from(data?['favorites'] ?? []);
  }
  @override
  Future<StoreModel> getCompanyById(String uid) async {
    final snapshot = await firestore.collection(AppCollection.users).doc(uid).get();
    return StoreModel.fromMap(snapshot.data()!);
  }

  @override
  Future<StoreModel?> getCompanyByPhone(String phone) async {
    final query = await firestore
        .collection(AppCollection.users)
        .where('phone', isEqualTo: phone)
        .where('role', isEqualTo: 'company')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return StoreModel.fromMap(query.docs.first.data());
    }
    return null;
  }

    @override
  Future<void> addFavorite(String userUid, String companyUid) async {
    await firestore.collection(AppCollection.users)
        .doc(userUid)
        .update({
      'favorites': FieldValue.arrayUnion([companyUid])
    });
  }
}