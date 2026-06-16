import 'package:flutter/material.dart';
import 'package:local_service_marketplace/models/question.dart';

class QuizQuestionWidget extends StatelessWidget {
  final Question question;
  final Function(int) onAnswerSelected;
  final List<int> hiddenAnswers;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    this.hiddenAnswers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:  0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(height: 30),

        ...List.generate(question.options.length, (index) {
          if (hiddenAnswers.contains(index)) {
            return const SizedBox.shrink();
          }

          return AnswerOption(
            text: question.options[index],
            index: index,
            isSelected: question.selectedAnswerIndex == index,
            onTap: () => onAnswerSelected(index),
          );
        }),
      ],
    );
  }
}

class AnswerOption extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  String get _optionLabel {
    switch (index) {
      case 0:
        return 'A';
      case 1:
        return 'B';
      case 2:
        return 'C';
      case 3:
        return 'D';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
          width: 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha:  0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _optionLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF1F2937),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
