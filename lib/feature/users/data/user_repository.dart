import 'package:barber/feature/users/models/store_model.dart';

abstract class UserRepository {
  Future<StoreModel?> getCompanyByPhone(String phone);
  Future<void> addFavorite(String userUid, String companyUid);
}
