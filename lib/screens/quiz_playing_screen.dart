import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/controllers/quiz_playing_controller.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/models/quiz.dart';
import 'package:local_service_marketplace/widget/Mathmatics%20Widget/quiz_process_bar.dart';
import 'package:local_service_marketplace/widget/Mathmatics%20Widget/quiz_question_widget.dart';
import 'package:local_service_marketplace/widget/Mathmatics%20Widget/quiz_timer.dart';

class QuizPlayingScreen extends StatelessWidget {
  final Quiz quiz;
  final QuizCategory category;

  const QuizPlayingScreen({
    super.key,
    required this.quiz,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      QuizPlayingController()
        ..quiz = quiz
        ..category = category,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Obx(() {
          // Loading State
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  const SizedBox(height: 20),
                  Text(
                    'Loading ${quiz.title}...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          // Empty Questions State
          if (controller.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No questions available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // HEADER (Close button, 50/50, Timer, Progress)
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Close Button
                        IconButton(
                          onPressed: controller.showExitDialog,
                          icon: const Icon(Icons.close),
                          color: const Color(0xFF6B7280),
                        ),

                        // 50/50 Button
                        ElevatedButton.icon(
                          onPressed: controller.isDisabled5050
                              ? null
                              : controller.use5050,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            elevation: controller.isDisabled5050 ? 0 : 4,
                          ),
                          icon: Icon(
                            Icons.star_half,
                            color: controller.isDisabled5050
                                ? Colors.grey[500]
                                : Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            '50:50 (${controller.fiftyFiftyUsesLeft.value})',
                            style: TextStyle(
                              color: controller.isDisabled5050
                                  ? Colors.grey[500]
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Timer
                        QuizTimer(
                          timeRemaining: controller.timeRemaining.value,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 10),
                    QuizProgressBar(
                      current: controller.currentQuestionIndex.value + 1,
                      total: controller.questions.length,
                    ),
                  ],
                ),
              ),

              // QUESTION AREA
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: QuizQuestionWidget(
                    question: controller.currentQuestion,
                    onAnswerSelected: controller.selectAnswer,
                    hiddenAnswers: controller.hiddenAnswers,
                  ),
                ),
              ),

              // BOTTOM NAVIGATION (Previous / Next)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (controller.currentQuestionIndex.value > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.previousQuestion,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(
                              color: Color(0xFF8B5CF6),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                    if (controller.currentQuestionIndex.value > 0)
                      const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: controller.canGoNext
                            ? (controller.isLastQuestion
                                  ? controller.submitQuiz
                                  : controller.nextQuestion)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          controller.isLastQuestion
                              ? 'Submit Quiz'
                              : 'Next Question',
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.canGoNext
                                ? Colors.white
                                : Colors.black38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
