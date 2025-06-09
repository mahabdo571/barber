part of 'user_search_cubit.dart';

@immutable
sealed class UserSearchState {}



class UserSearchInitial extends UserSearchState {}
class UserSearchLoading extends UserSearchState {}
class UserSearchSuccess extends UserSearchState {
  final StoreModel user;
  UserSearchSuccess(this.user);
}
class FavoritesListLoadedSuccessfully extends UserSearchState {
  final List<StoreModel> list;
  FavoritesListLoadedSuccessfully(this.list);
}
class UserSearchEmpty extends UserSearchState {}
class UserSearchFavoriteSuccess extends UserSearchState {}

class UserSearchError extends UserSearchState {
  final String message;
  UserSearchError(this.message);
}