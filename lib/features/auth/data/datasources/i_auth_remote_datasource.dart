import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/data/models/user_model.dart';
import 'package:shopkeeper/features/auth/domain/entities/shop_summary.dart';

abstract class IAuthRemoteDataSource {
  Future<UserModel> login(String email, String password, UserRole role);
  Future<UserModel> register(
      {required String name, required String email, required String password});
  Future<String> registerShop({required String shopName});
  Future<UserModel> refreshSession();
  Future<void> logout();

  /// Sends a password-reset OTP to [email]. Always succeeds on the server
  /// regardless of whether the email is registered (enumeration prevention).
  Future<void> forgotPassword(String email);

  /// Validates the OTP [code] and sets [newPassword] as the new password.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Submits the email-verification OTP. Returns updated user with emailVerified=true.
  Future<UserModel> verifyEmail(String code);

  /// Requests a new email-verification OTP.
  Future<void> resendVerificationCode();

  /// Fetches the owner's first shop and returns its name and description.
  Future<({String name, String description})> fetchShopInfo();

  /// Fetches the shop info for the currently authenticated staff member.
  Future<({String name, String description})> fetchStaffShopInfo();

  /// Updates the shop identified by [shopId] with new [name] and [description].
  Future<void> updateShop({
    required String shopId,
    required String name,
    required String description,
  });

  /// Fetches a single shop by [shopId].
  Future<({String name, String description})> fetchShopById(String shopId);

  /// Fetches all shops owned by the authenticated user.
  Future<List<ShopSummary>> fetchAllShops();
}
