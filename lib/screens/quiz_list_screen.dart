import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/controllers/quiz_list_controller.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/widget/Mathmatics%20Widget/quiz_list_header.dart';
import 'package:local_service_marketplace/widget/Mathmatics%20Widget/quiz_list_item.dart';

class QuizListScreen extends StatelessWidget {
  final QuizCategory category;

  const QuizListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
 
    final controller = Get.put(QuizListController()..category = category);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            
            QuizListHeader(category: category, onBack: () => Get.back()),

            //  Reactive Quiz List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  );
                }

                // Empty State
                if (controller.quizzes.isEmpty) {
                  return _buildEmptyState(category);
                }

                // Quiz List
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: controller.quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = controller.quizzes[index];
                    final bool isLocked = controller.isQuizLocked(quiz.id);

                    return QuizListItem(
                      quiz: quiz,
                      isLocked: isLocked,
                      onTap: isLocked
                          ? controller.showLockedMessage
                          : () => controller.startQuiz(quiz),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  ///  Empty State Widget
  Widget _buildEmptyState(QuizCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(category.icon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Coming Soon!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${category.name} quizzes are being prepared',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go Back', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
