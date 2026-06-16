import 'package:flutter/material.dart';
import 'package:local_service_marketplace/models/quiz.dart';

class QuizListItem extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;
  final bool isLocked;

  const QuizListItem({
    super.key,
    required this.quiz,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isLocked)
            BoxShadow(
              color: Colors.grey.withValues(alpha:  0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey[300]
                              : const Color(0xFF3B82F6).withValues(alpha:  0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          quiz.iconEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLocked
                                    ? Colors.grey[700]
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLocked ? "Completed" : quiz.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isLocked
                                    ? Colors.green
                                    : const Color(0xFF6B7280),
                                fontWeight: isLocked
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            QuizInfoChip(
                              icon: Icons.help_outline,
                              label: '${quiz.questionCount} Qs',
                              color: isLocked ? Colors.grey : Colors.blue,
                            ),
                            QuizInfoChip(
                              icon: Icons.timer_outlined,
                              label: '${quiz.duration}m',
                              color: isLocked ? Colors.grey : Colors.orange,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? Colors.grey[300]
                                    : quiz.difficultyColor.withValues(alpha:  0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                quiz.difficultyText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLocked
                                      ? Colors.grey[600]
                                      : quiz.difficultyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey[400]
                              : const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isLocked ? Icons.lock : Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const QuizInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
