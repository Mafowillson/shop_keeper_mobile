import 'package:flutter/foundation.dart';
import 'package:shopkeeper/core/enums/user_role.dart';

@immutable
class User {
  final String id;
  final String shopId;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  const User({
    required this.id,
    required this.shopId,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  User copyWith({
    String? id,
    String? shopId,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  }) =>
      User(
        id: id ?? this.id,
        shopId: shopId ?? this.shopId,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
      );
}
