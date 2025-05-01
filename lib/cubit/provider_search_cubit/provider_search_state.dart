import '../../models/provider_model.dart';

/// Possible states of the search feature
enum ProviderSearchStatus { initial,ItsInFavorites,added, loading, success, notFound, error }

/// State class for ProviderSearchCubit
class ProviderSearchState {
  final ProviderSearchStatus status;
  final ProviderModel? provider;
  final bool addedToFavorites;
  final String errorMessage;

  ProviderSearchState({
    required this.status,
    this.provider,
    this.addedToFavorites = false,
    this.errorMessage = '',
  });

  factory ProviderSearchState.initial() {
    return ProviderSearchState(status: ProviderSearchStatus.initial);
  }

  ProviderSearchState copyWith({
    ProviderSearchStatus? status,
    ProviderModel? provider,
    bool? addedToFavorites,
    String? errorMessage,
  }) {
    return ProviderSearchState(
      status: status ?? this.status,
      provider: provider ?? this.provider,
      addedToFavorites: addedToFavorites ?? this.addedToFavorites,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
