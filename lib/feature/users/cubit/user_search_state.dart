part of 'user_search_cubit.dart';

@immutable
sealed class UserSearchState {}



class UserSearchInitial extends UserSearchState {}
class UserSearchLoading extends UserSearchState {}
class UserSearchSuccess extends UserSearchState {
  final UserModel user;
  UserSearchSuccess(this.user);
}
class UserSearchEmpty extends UserSearchState {}
class UserSearchError extends UserSearchState {
  final String message;
  UserSearchError(this.message);
}