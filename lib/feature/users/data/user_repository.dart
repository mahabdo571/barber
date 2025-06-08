

import 'package:barber/feature/users/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserByPhoneAndRole(String phone, String role);
}
