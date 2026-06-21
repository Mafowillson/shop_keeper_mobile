import 'package:shopkeeper/features/ai/weekly_insights/domain/entities/weekly_insight.dart';

class WeeklyInsightModel {
  final String id;
  final String shopId;
  final DateTime weekStart;
  final String content;
  final DateTime generatedAt;

  const WeeklyInsightModel({
    required this.id,
    required this.shopId,
    required this.weekStart,
    required this.content,
    required this.generatedAt,
  });

  factory WeeklyInsightModel.fromJson(Map<String, dynamic> json) =>
      WeeklyInsightModel(
        id: json['id'] as String,
        shopId: json['shop_id'] as String,
        weekStart: DateTime.parse(json['week_start'] as String),
        content: json['content'] as String? ?? '',
        generatedAt: DateTime.parse(json['generated_at'] as String),
      );

  WeeklyInsight toEntity() => WeeklyInsight(
        id: id,
        shopId: shopId,
        weekStart: weekStart,
        content: content,
        generatedAt: generatedAt,
      );
}
