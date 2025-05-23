import 'package:barber/core/constants/app_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final _col = FirebaseFirestore.
  instance.
  collection(AppCollection.users);

  Future<void> saveUser(UserModel user) {
    return _col.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }
}
