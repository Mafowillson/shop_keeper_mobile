import 'package:flutter/foundation.dart';

@immutable
class WeeklyInsight {
  final String id;
  final String shopId;
  final DateTime weekStart;
  final String content;
  final DateTime generatedAt;

  const WeeklyInsight({
    required this.id,
    required this.shopId,
    required this.weekStart,
    required this.content,
    required this.generatedAt,
  });

  String get weekLabel {
    final day = weekStart.day;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Week of $day ${months[weekStart.month - 1]} ${weekStart.year}';
  }
}
