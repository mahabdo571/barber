
import 'package:barber/core/constants/app_collection.dart';
import 'package:barber/feature/users/data/user_repository.dart';
import 'package:barber/feature/users/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore firestore;

  UserRepositoryImpl(this.firestore);

  @override
  Future<UserModel?> getUserByPhoneAndRole(String phone, String role) async {
    final query = await firestore
        .collection(AppCollection.users)
        .where('phone', isEqualTo: phone)
        .where('role', isEqualTo: role)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return UserModel.fromMap(query.docs.first.data());
    }
    return null;
  }
}