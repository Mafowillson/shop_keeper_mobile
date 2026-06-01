import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String shopId;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final bool emailVerified;

  const UserModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.emailVerified = false,
  });

  // ── Backend response parsers ────────────────────────────────────────────

  factory UserModel.fromOwnerLoginResponse(Map<String, dynamic> json) {
    final u = json['user'] as Map<String, dynamic>;
    return UserModel(
      id: u['id'] as String,
      shopId: u['shop_id'] as String? ?? '',
      name: u['name'] as String? ?? '',
      email: u['email'] as String,
      role: UserRole.owner,
      isActive: true,
      emailVerified: u['email_verified'] as bool? ?? false,
    );
  }

  factory UserModel.fromStaffLoginResponse(Map<String, dynamic> json) {
    final s = json['staff'] as Map<String, dynamic>;
    return UserModel(
      id: s['id'] as String,
      shopId: s['shop_id'] as String? ?? '',
      name: s['name'] as String? ?? '',
      email: s['email'] as String,
      role: UserRole.staff,
      isActive: s['is_active'] as bool? ?? true,
      // Staff accounts are created by the owner — no email verification needed.
      emailVerified: true,
    );
  }

  // ── Hive persistence (plain JSON string) ────────────────────────────────

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        shopId: json['shop_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.name == json['role'],
          orElse: () => UserRole.owner,
        ),
        isActive: json['is_active'] as bool? ?? true,
        emailVerified: json['email_verified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'shop_id': shopId,
        'name': name,
        'email': email,
        'role': role.name,
        'is_active': isActive,
        'email_verified': emailVerified,
      };

  // ── Entity conversion ────────────────────────────────────────────────────

  factory UserModel.fromEntity(User entity) => UserModel(
        id: entity.id,
        shopId: entity.shopId,
        name: entity.name,
        email: entity.email,
        role: entity.role,
        isActive: entity.isActive,
        emailVerified: entity.emailVerified,
      );

  User toEntity() => User(
        id: id,
        shopId: shopId,
        name: name,
        email: email,
        role: role,
        isActive: isActive,
        emailVerified: emailVerified,
      );

  UserModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    bool? emailVerified,
  }) =>
      UserModel(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        emailVerified: emailVerified ?? this.emailVerified,
      );
}
