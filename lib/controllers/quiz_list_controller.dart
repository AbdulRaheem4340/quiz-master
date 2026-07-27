import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_service.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/models/quiz.dart';
import 'package:local_service_marketplace/screens/quiz_playing_screen.dart';

class QuizListController extends GetxController {
  final FirebaseService _firebase = FirebaseService();

  // Parameter passed from QuizListScreen
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

  // ─────────────────────────────────────────────────────
  // LOAD QUIZZES
  // ─────────────────────────────────────────────────────
  Future<void> loadQuizzes() async {
    isLoading.value = true;

    try {
      // 1. Fetch all quizzes for this category
      final result = await _firebase.getQuizzesByCategory(category.id);

      // 2. Fetch which quizzes user already played
      List<int> playedIds = await _firebase.getPlayedQuizIds(category.id);

      debugPrint('📋 Total quizzes: ${result.length}');
      debugPrint('🔒 Played (locked) quiz IDs: $playedIds');

      // 3. If ALL quizzes are played → RESET everything → ALL OPEN AGAIN
      if (result.isNotEmpty && playedIds.length >= result.length) {
        debugPrint('🔄 All quizzes completed! Resetting...');

        // Reset in Firebase
        await _firebase.resetPlayedQuizIds(category.id);

        // Reset locally
        playedIds = [];

        debugPrint('✅ Reset done! All quizzes are OPEN again!');
      }

      // 4. Update state
      quizzes.value = result;
      playedQuizIds.value = playedIds;

    } catch (e) {
      debugPrint('❌ Error loading quizzes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────
  // IS QUIZ LOCKED?
  //
  // SIMPLE RULE:
  // ✅ Quiz is in playedQuizIds → LOCKED
  // ✅ Quiz is NOT in playedQuizIds → OPEN
  // ─────────────────────────────────────────────────────
  bool isQuizLocked(int quizId) {
    // If quiz is already played → LOCKED
    // If quiz is not played yet → OPEN
    return playedQuizIds.contains(quizId);
  }

  // ─────────────────────────────────────────────────────
  // START QUIZ
  // ─────────────────────────────────────────────────────
  void startQuiz(Quiz quiz) async {
    // Safety check
    if (isQuizLocked(quiz.id)) {
      showLockedMessage();
      return;
    }

    // Go to quiz playing screen
    await Get.to(() => QuizPlayingScreen(
      quiz: quiz,
      category: category,
    ));

    // Reload after returning (quiz completed → now locked)
    await loadQuizzes();
  }

  // ─────────────────────────────────────────────────────
  // SHOW LOCKED MESSAGE
  // ─────────────────────────────────────────────────────
  void showLockedMessage() {
    Get.snackbar(
      '🔒 Already Played',
      'You already completed this quiz! Play remaining quizzes to unlock it again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.lock_outline, color: Colors.white),
    );
  }

  // ─────────────────────────────────────────────────────
  // PROGRESS HELPERS (for UI)
  // ─────────────────────────────────────────────────────
  int get completedCount => playedQuizIds.length;
  int get totalCount => quizzes.length;
  int get remainingCount => totalCount - completedCount;
  double get progressPercentage =>
      totalCount > 0 ? completedCount / totalCount : 0.0;
}