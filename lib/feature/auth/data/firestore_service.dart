import 'package:barber/core/constants/app_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final _col = FirebaseFirestore.instance.collection(AppCollection.users);

  Future<void> saveUser(Object? user) {
    UserModel model = user as UserModel;
    return _col.doc(model.uid).set(model.toMap());
  }

  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }
}
