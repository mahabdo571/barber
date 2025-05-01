
import 'package:barber/constants.dart';
import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/models/favorit_model.dart';
import 'package:barber/models/favorit_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class FierstoreFavoritRepository implements FavoritRepository {
  final FirebaseFirestore _firestore;
  final _authCubit = GetIt.I<AuthCubit>();

  FierstoreFavoritRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _customerColl =>
      _firestore.collection(kDBUser);
  @override
  Future<void> addFavorit(FavoritModel favorit) {
    // TODO: implement addFavorit
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFavorit(String favoritId) {
    // TODO: implement deleteFavorit
    throw UnimplementedError();
  }

  @override
  Future<List<FavoritModel>> getFavoritByCustomerId(String customerId)async {

    final userDoc = _firestore.doc(customerId);
    final favCollection = userDoc.collection('favorites');
    final snapshot = await favCollection.get();
    return snapshot.docs
        .map((doc) => FavoritModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<FavoritModel> getFavoritById(String favoritId) {
    // TODO: implement getFavoritById
    throw UnimplementedError();
  }

  @override
  Future<void> updateFavorit(FavoritModel favorit) {
    // TODO: implement updateFavorit
    throw UnimplementedError();
  }
 

}