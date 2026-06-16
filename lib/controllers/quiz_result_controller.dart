import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/models/question.dart';
import 'package:local_service_marketplace/models/quiz.dart';
import 'package:local_service_marketplace/screens/home_screen.dart';
import 'package:local_service_marketplace/screens/quiz_review_screen.dart';

class QuizResultController extends GetxController {
  // Parameters
  late Quiz quiz;
  late QuizCategory category;
  late List<Question> questions;
  late int score;
  late int correctAnswers;
  late int totalQuestions;
  late int timeTaken;

  // Calculated properties
  double get percentage => (correctAnswers / totalQuestions) * 100;
  int get wrongAnswers => totalQuestions - correctAnswers;

  String get formattedTime {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes}m ${seconds}s';
  }

  ///   Get color based on performance
  Color get scoreColor {
    if (percentage >= 80) return const Color(0xFF10B981); 
    if (percentage >= 50) return const Color(0xFFF59E0B); 
    return const Color(0xFFEF4444); 
  }

  ///   Get message based on performance
  String get performanceMessage {
    if (percentage == 100) return 'Perfect Score! 🏆';
    if (percentage >= 80) return 'Excellent Work! 🌟';
    if (percentage >= 60) return 'Good Job! 👏';
    if (percentage >= 40) return 'Keep Practicing! 💪';
    return 'Try Again! 📚';
  }

  ///  Navigate to Review Screen
  void reviewAnswers() {
    Get.to(() => QuizReviewScreen(quiz: quiz, questions: questions));
  }

  ///   Go back to Home
  void goHome() {
    Get.offAll(() => const HomeScreen());
  }
}