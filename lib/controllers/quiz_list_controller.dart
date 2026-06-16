import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_service.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/models/quiz.dart';
import 'package:local_service_marketplace/screens/quiz_playing_screen.dart';

class QuizListController extends GetxController {
  final FirebaseService _firebase = FirebaseService();

  // Parameter passed from HomeScreen
  late QuizCategory category;

  // Observable State
  final RxList<Quiz> quizzes = <Quiz>[].obs;
  final RxList<int> playedQuizIds = <int>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuizzes();
  }

  ///  Load all quizzes for this category
  Future<void> loadQuizzes() async {
    isLoading.value = true;

    try {
      final result = await _firebase.getQuizzesByCategory(category.id);
      List<int> playedIds = await _firebase.getPlayedQuizIds(category.id);

      //  Reset locks if user completed ALL quizzes in this category
      if (playedIds.length >= result.length && result.isNotEmpty) {
        playedIds.clear();
      }

      quizzes.value = result;
      playedQuizIds.value = playedIds;
    } catch (e) {
      debugPrint('❌ Error loading quizzes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  ///  Start a quiz
  void startQuiz(Quiz quiz) async {
    await Get.to(() => QuizPlayingScreen(quiz: quiz, category: category));
    loadQuizzes();
  }

  ///  Show "locked" message
  void showLockedMessage() {
    Get.snackbar(
      'Quiz Locked',
      'You must finish the other quizzes first! 🔒',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Check if a quiz is locked
  bool isQuizLocked(int quizId) => playedQuizIds.contains(quizId);
}