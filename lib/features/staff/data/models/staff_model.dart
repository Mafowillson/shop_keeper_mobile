import 'package:shopkeeper/features/staff/domain/entities/staff_entity.dart';

class StaffModel {
  final String id;
  final String ownerId;
  final String shopId;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;

  const StaffModel({
    required this.id,
    required this.ownerId,
    required this.shopId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isActive,
    required this.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String? ?? '',
        shopId: json['shop_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String,
        phoneNumber: json['phone_number'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  StaffEntity toEntity() => StaffEntity(
        id: id,
        ownerId: ownerId,
        shopId: shopId,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        isActive: isActive,
        createdAt: createdAt,
      );
}
