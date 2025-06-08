import 'package:barber/feature/users/data/user_repository.dart';
import 'package:barber/feature/users/models/user_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_search_state.dart';

class UserSearchCubit extends Cubit<UserSearchState> {

     final UserRepository repository;

  UserSearchCubit(this.repository) : super(UserSearchInitial());

  Future<void> searchUser(String phone, String role) async {
    emit(UserSearchLoading());
    try {
      final user = await repository.getUserByPhoneAndRole(phone, role);
      if (user != null) {
        emit(UserSearchSuccess(user));
      } else {
        emit(UserSearchEmpty());
      }
    } catch (e) {
      emit(UserSearchError(e.toString()));
    }
  }
}
