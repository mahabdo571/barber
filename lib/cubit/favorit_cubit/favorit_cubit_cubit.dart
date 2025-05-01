import 'package:barber/models/favorit_model.dart';
import 'package:barber/models/favorit_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'favorit_cubit_state.dart';

class FavoritCubitCubit extends Cubit<FavoritCubitState> {
  final FavoritRepository _repository;

  FavoritCubitCubit({required FavoritRepository repository})
    : _repository = repository,
      super(FavoritCubitInitial());

  Future<void> loadFavoritByCoustomerId() async {
    emit(FavoritLoading());
    try {
      final favorits = await _repository.getFavoritByCustomerId();
      emit(FavoritSuccess(favorits: favorits));
    } catch (e) {
      emit(FavoritFailure(e.toString()));
    }
  }
}
