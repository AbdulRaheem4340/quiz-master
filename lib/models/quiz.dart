import 'package:flutter/material.dart';

enum QuizDifficulty { easy, medium, hard }

class Quiz {
  final int id;
  final int categoryId;
  final String title;
  final String description;
  final QuizDifficulty difficulty;
  final int questionCount;
  final int duration;
  final int totalPoints;
  final String iconEmoji;

  Quiz({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questionCount,
    required this.duration,
    required this.totalPoints,
    required this.iconEmoji,
  });

  // ✅ ADD THIS FACTORY CONSTRUCTOR
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? 0,
      categoryId: map['categoryId'] ?? 0,
      title: map['title'] ?? 'Untitled Quiz',
      description: map['description'] ?? '',
      difficulty: _parseDifficulty(map['difficulty']),
      questionCount: map['questionCount'] ?? 0,
      duration: map['duration'] ?? 10,
      totalPoints: map['totalPoints'] ?? 100,
      iconEmoji: map['iconEmoji'] ?? '📝',
    );
  }

  // Difficulty helpers
  static QuizDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return QuizDifficulty.easy;
      case 'hard':
        return QuizDifficulty.hard;
      default:
        return QuizDifficulty.medium;
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Colors.green;
      case QuizDifficulty.medium:
        return Colors.orange;
      case QuizDifficulty.hard:
        return Colors.red;
    }
  }

  String get difficultyText {
    return difficulty.name[0].toUpperCase() + difficulty.name.substring(1);
  }
}