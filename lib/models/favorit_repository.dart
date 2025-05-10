import 'favorit_model.dart';

abstract class FavoritRepository {
  Future<List<FavoritModel>> getFavoritByCustomerId();
  Future<FavoritModel> getFavoritById(String favoritId);
  Future<void> addFavorit(FavoritModel favorit);
  Future<void> updateFavorit(FavoritModel favorit);
  Future<void> deleteFavorit(String favoritId);
}
