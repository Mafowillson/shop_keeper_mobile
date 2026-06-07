import 'dart:convert';

enum SyncEntityType { product, sale, customer, debtRecord }

enum SyncOperationType { create, update, delete, payment }

enum SyncEntryStatus { pending, synced, conflict }

class SyncLogEntry {
  final String id;
  final String deviceId;
  final SyncEntityType entityType;
  final SyncOperationType operationType;
  final Map<String, dynamic> payload;
  final SyncEntryStatus status;
  final DateTime timestamp;

  const SyncLogEntry({
    required this.id,
    required this.deviceId,
    required this.entityType,
    required this.operationType,
    required this.payload,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_id': deviceId,
        'entity_type': entityType.name,
        'operation_type': operationType.name,
        'payload': payload,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SyncLogEntry.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    final Map<String, dynamic> payload;
    if (rawPayload is String) {
      payload = jsonDecode(rawPayload) as Map<String, dynamic>;
    } else {
      payload = (rawPayload as Map?)?.cast<String, dynamic>() ?? {};
    }
    return SyncLogEntry(
      id: json['id'] as String,
      deviceId: json['device_id'] as String? ?? '',
      entityType: SyncEntityType.values.byName(json['entity_type'] as String),
      operationType:
          SyncOperationType.values.byName(json['operation_type'] as String),
      payload: payload,
      status: SyncEntryStatus.values.byName(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  SyncLogEntry copyWith({SyncEntryStatus? status}) => SyncLogEntry(
        id: id,
        deviceId: deviceId,
        entityType: entityType,
        operationType: operationType,
        payload: payload,
        status: status ?? this.status,
        timestamp: timestamp,
      );
}
