class StaffEntity {
  final String id;
  final String ownerId;
  final String shopId;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isActive;
  final DateTime createdAt;

  const StaffEntity({
    required this.id,
    required this.ownerId,
    required this.shopId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isActive,
    required this.createdAt,
  });
}
