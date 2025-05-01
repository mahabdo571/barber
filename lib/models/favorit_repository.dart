import 'package:barber/models/favorit_model.dart';

abstract class FavoritRepository {
  Future<List<FavoritModel>> getFavoritByCustomerId(String customerId);
  Future<FavoritModel> getFavoritById(String favoritId);
  Future<void> addFavorit(FavoritModel favorit);
  Future<void> updateFavorit(FavoritModel favorit);
  Future<void> deleteFavorit(String favoritId);
}
