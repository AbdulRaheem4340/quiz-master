import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/audio_quiz_service.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_service.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/models/question.dart';
import 'package:local_service_marketplace/models/quiz.dart';
import 'package:local_service_marketplace/screens/quiz_result_screen.dart';

class QuizPlayingController extends GetxController {
  final FirebaseService _firebase = FirebaseService();

  // PARAMETERS (Passed from QuizListScreen)
  late Quiz quiz;
  late QuizCategory category;

  // OBSERVABLE STATE
  final RxList<Question> questions = <Question>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxInt timeRemaining = 0.obs;
  final RxBool isLoading = true.obs;

  // 50/50 Lifeline
  final RxInt fiftyFiftyUsesLeft = 2.obs;
  final RxBool used5050OnThisQuestion = false.obs;
  final RxList<int> hiddenAnswers = <int>[].obs;

  // Timer
  Timer? _timer;

  // LIFECYCLE
  @override
  void onInit() {
    super.onInit();
    loadQuestions();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // LOAD QUESTIONS

  Future<void> loadQuestions() async {
    isLoading.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final result = await _firebase.getQuestions(quiz.id);
      questions.value = result;
      timeRemaining.value = quiz.duration * 60;

      if (questions.isNotEmpty) {
        _startTimer();
      }
    } catch (e) {
      debugPrint('❌ Error loading questions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // TIMER
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        _timer?.cancel();
        submitQuiz();
      }
    });
  }

  // 50/50 LIFELINE LOGIC
  void use5050() {
    if (fiftyFiftyUsesLeft.value <= 0 || used5050OnThisQuestion.value) return;

    final currentQuestion = questions[currentQuestionIndex.value];
    List<int> wrongIndices = [];

    for (int i = 0; i < currentQuestion.options.length; i++) {
      if (i != currentQuestion.correctAnswerIndex) {
        wrongIndices.add(i);
      }
    }

    wrongIndices.shuffle();

    hiddenAnswers.value = [wrongIndices[0], wrongIndices[1]];
    fiftyFiftyUsesLeft.value--;
    used5050OnThisQuestion.value = true;
  }

  // ANSWER SELECTION
  void selectAnswer(int answerIndex) {
    if (questions[currentQuestionIndex.value].isAnswered) return;

    questions[currentQuestionIndex.value].selectedAnswerIndex = answerIndex;
    questions.refresh();

    bool isCorrect =
        questions[currentQuestionIndex.value].correctAnswerIndex == answerIndex;

    if (isCorrect) {
      QuizAudioService.playCorrect();
    } else {
      QuizAudioService.playWrong();
    }
  }

  // NAVIGATION (Next/Previous Question)
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      hiddenAnswers.clear();
      used5050OnThisQuestion.value = false;
    } else {
      submitQuiz();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      hiddenAnswers.clear();
      used5050OnThisQuestion.value = false;
    }
  }

  // SUBMIT QUIZ
  void submitQuiz() {
    _timer?.cancel();

    int correctAnswers = 0;
    int totalScore = 0;

    for (var question in questions) {
      if (question.isCorrect) {
        correctAnswers++;
        totalScore += question.points;
      }
    }
    score.value = totalScore;

    QuizAudioService.playCongrats();

    // Save result to Firebase
    _firebase.submitQuizResult(
      quizId: quiz.id,
      categoryId: category.id,
      quizTitle: quiz.title,
      categoryName: category.name,
      score: totalScore,
      totalScore: quiz.totalPoints,
      correctAnswers: correctAnswers,
      totalQuestions: questions.length,
      timeTaken: (quiz.duration * 60) - timeRemaining.value,
    );

    // Navigate to Result Screen
    Get.offAll(
      () => QuizResultScreen(
        quiz: quiz,
        category: category,
        questions: questions,
        score: totalScore,
        correctAnswers: correctAnswers,
        totalQuestions: questions.length,
        timeTaken: (quiz.duration * 60) - timeRemaining.value,
      ),
    );
  }

  // EXIT DIALOG

  void showExitDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Get.back(); // Close dialog
              Get.back(); // Close quiz screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  // HELPERS
  Question get currentQuestion => questions[currentQuestionIndex.value];

  bool get isDisabled5050 =>
      fiftyFiftyUsesLeft.value <= 0 ||
      used5050OnThisQuestion.value ||
      (questions.isNotEmpty &&
          questions[currentQuestionIndex.value].isAnswered);

  bool get canGoNext =>
      questions.isNotEmpty && questions[currentQuestionIndex.value].isAnswered;

  bool get isLastQuestion => currentQuestionIndex.value == questions.length - 1;
}
