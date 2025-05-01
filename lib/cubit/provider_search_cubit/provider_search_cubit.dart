import 'package:barber/Repository/provider/provider_pepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'provider_search_state.dart';
import '../../models/provider_model.dart';

/// Cubit to manage provider search & favorites
class ProviderSearchCubit extends Cubit<ProviderSearchState> {
  final ProviderRepository _repository;

  ProviderSearchCubit({required ProviderRepository repository})
    : _repository = repository,
      super(ProviderSearchState.initial());

  /// Search for a provider by phone
  Future<void> searchProvider(String phone) async {
    emit(state.copyWith(status: ProviderSearchStatus.loading));
    try {
      final provider = await _repository.searchProviderByPhone(phone);
      if (provider != null) {
        emit(
          state.copyWith(
            status: ProviderSearchStatus.success,
            provider: provider,
          ),
        );
      } else {
        emit(state.copyWith(status: ProviderSearchStatus.notFound));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProviderSearchStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Add the found provider to customer's favorites
  Future<void> addProviderToFavorites(String customerId) async {
    if (state.provider != null) {
      await _repository.addProviderToFavorites(
        customerId: customerId,
        provider: state.provider!,
      );
      emit(
        state.copyWith(
          addedToFavorites: true,
          status: ProviderSearchStatus.success,
        ),
      );
    }
  }

  Future<void> checkItsInFavorites(String customerId) async {
    if (state.provider != null) {
      if (await _repository.isProviderInFavorite(
        customerId: customerId,
        providerId: state.provider!.uid,
      )) {
        emit(state.copyWith(status: ProviderSearchStatus.ItsInFavorites));
      } else {
        emit(state.copyWith(status: ProviderSearchStatus.notFound));
      }
    }
  }

  /// Reset to initial
  void reset() {
    emit(ProviderSearchState.initial());
  }
}
