import 'package:flutter/material.dart';

class QuizCategory {
  final int id;
  final String name;
  final String icon;
  final Color color;
  final String description;
  final int quizCount;

  QuizCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.quizCount,
  });

  factory QuizCategory.fromMap(Map<String, dynamic> map) {
    return QuizCategory(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Unknown',
      icon: map['icon'] ?? '❓',
      description: map['description'] ?? '',
      quizCount: map['quizCount'] ?? 0,
      color: _hexToColor(map['color'] ?? '#8B5CF6'),
    );
  }

  static Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
