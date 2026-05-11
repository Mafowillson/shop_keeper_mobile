import 'package:shopkeeper/core/enums/user_role.dart';
import 'package:shopkeeper/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String shopId;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    shopId: json['shop_id'],
    name: json['name'],
    email: json['email'],
    role: UserRole.values.firstWhere((e) => e.toString() == 'UserRole.${json['role']}'),
    isActive: json['is_active'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'name': name,
    'email': email,
    'role': role.toString().split('.').last,
    'is_active': isActive,
  };

  factory UserModel.fromEntity(User entity) => UserModel(
    id: entity.id,
    shopId: entity.shopId,
    name: entity.name,
    email: entity.email,
    role: entity.role,
    isActive: entity.isActive,
  );

  User toEntity() => User(
    id: id,
    shopId: shopId,
    name: name,
    email: email,
    role: role,
    isActive: isActive,
  );

  UserModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  }) =>
      UserModel(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
      );
}
