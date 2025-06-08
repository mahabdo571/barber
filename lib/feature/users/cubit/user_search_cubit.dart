import 'package:barber/feature/users/data/user_repository.dart';
import 'package:barber/feature/users/models/store_model.dart';
import 'package:barber/feature/users/models/user_model.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'user_search_state.dart';

class UserSearchCubit extends Cubit<UserSearchState> {

     final UserRepository repository;

  UserSearchCubit(this.repository) : super(UserSearchInitial());

  Future<void> searchCompany(String phone) async {
    emit(UserSearchLoading());
    try {
      final user = await repository.getCompanyByPhone(phone);
      if (user != null) {
        emit(UserSearchSuccess(user));
      } else {
        emit(UserSearchEmpty());
      }
    } catch (e) {
      emit(UserSearchError(e.toString()));
    }
  }

    Future<void> addFavorite(String companyUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      emit(UserSearchError('يجب تسجيل الدخول أولاً'));
      return;
    }
    try {
      await repository.addFavorite(currentUser.uid, companyUid);
      emit(UserSearchFavoriteSuccess());
    } catch (e) {
      emit(UserSearchError(e.toString()));
    }
  }
}
