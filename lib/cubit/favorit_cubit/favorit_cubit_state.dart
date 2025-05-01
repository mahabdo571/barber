part of 'favorit_cubit_cubit.dart';

sealed class FavoritCubitState extends Equatable {
  const FavoritCubitState();

  @override
  List<Object?> get props => [];
}

final class FavoritCubitInitial extends FavoritCubitState {}

final class FavoritLoading extends FavoritCubitState {}

final class FavoritSuccess extends FavoritCubitState {
  final List<FavoritModel> favorits;

  FavoritSuccess({required this.favorits});
}

class FavoritFailure extends FavoritCubitState {
  final String error;
  FavoritFailure(this.error);

  @override
  List<Object?> get props => [error];
}
