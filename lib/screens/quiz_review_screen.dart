import 'package:flutter/material.dart';
import 'package:local_service_marketplace/models/question.dart';
import 'package:local_service_marketplace/models/quiz.dart';
import 'package:local_service_marketplace/widget/Mathmatics%20Widget/review_question_card.dart';


class QuizReviewScreen extends StatelessWidget {
  final Quiz quiz;
  final List<Question> questions;

  const QuizReviewScreen({
    super.key,
    required this.quiz,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
        ),
        title: const Text(
          'Review Answers',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ReviewQuestionCard(
            question: questions[index],
            questionNumber: index + 1,
          );
        },
      ),
    );
  }
}
