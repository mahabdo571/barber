import 'package:barber/models/provider_model.dart';

abstract class ProviderRepository {
  /// Search a provider by phone number
  Future<ProviderModel?> searchProviderByPhone(String phone);

  /// Add a provider to a customer's favorites
  Future<void> addProviderToFavorites({
    required String customerId,
    required ProviderModel provider,
  });
}