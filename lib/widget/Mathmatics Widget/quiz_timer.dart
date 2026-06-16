import 'package:flutter/material.dart';

class QuizTimer extends StatelessWidget {
  final int timeRemaining;

  const QuizTimer({super.key, required this.timeRemaining});

  String get _formattedTime {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (timeRemaining <= 60) return Colors.red;
    if (timeRemaining <= 180) return Colors.orange;
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _timerColor.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: _timerColor, size: 20),
          const SizedBox(width: 5),
          Text(
            _formattedTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _timerColor,
            ),
          ),
        ],
      ),
    );
  }
}
