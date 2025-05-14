abstract class AuthRepository {
  Future<String> signInWithPhone(String phoneNumber);
  Future<String> verifyOTP(String verificationId, String otp);
  Future<void> signOut();
  Future<bool> isSignedIn();
  Future<String?> getCurrentUserId();
  Future<void> setUserRole(String role);
  Future<String?> getUserRole();
}
