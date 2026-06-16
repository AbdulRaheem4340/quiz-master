import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_service.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/models/quiz.dart';
import 'package:local_service_marketplace/screens/quiz_playing_screen.dart';

class ExploreController extends GetxController {
  final FirebaseService _firebase = FirebaseService();

  final RxList<Quiz> allQuizzes = <Quiz>[].obs;
  final RxList<Quiz> filteredQuizzes = <Quiz>[].obs;
  final RxList<QuizCategory> categories = <QuizCategory>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadExploreData();
  }

  Future<void> loadExploreData() async {
    try {
      isLoading.value = true;

      final results = await Future.wait<dynamic>([
        _firebase.getAllQuizzes(),
        _firebase.getCategories(),
      ]);

      allQuizzes.value = results[0] as List<Quiz>;
      filteredQuizzes.value = allQuizzes.toList();
      categories.value = results[1] as List<QuizCategory>;

      debugPrint(
        '✅ Explore loaded: ${allQuizzes.length} quizzes, ${categories.length} categories',
      );
    } catch (e) {
      debugPrint('❌ Error loading explore: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterQuizzes(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredQuizzes.value = allQuizzes.toList();
    } else {
      filteredQuizzes.value = allQuizzes
          .where(
            (quiz) =>
                quiz.title.toLowerCase().contains(query.toLowerCase()) ||
                quiz.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  void startQuiz(Quiz quiz) {
    final QuizCategory category = categories.firstWhere(
      (cat) => cat.id == quiz.categoryId,
      orElse: () => QuizCategory(
        id: 0,
        name: 'Unknown',
        icon: '❓',
        color: Colors.grey,
        description: '',
        quizCount: 0,
      ),
    );
    Get.to(() => QuizPlayingScreen(quiz: quiz, category: category));
  }

  String getCategoryName(int categoryId) {
    return categories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => QuizCategory(
            id: 0,
            name: 'General',
            icon: '',
            color: Colors.grey,
            description: '',
            quizCount: 0,
          ),
        )
        .name;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
