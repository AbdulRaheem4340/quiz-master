import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final int totalScore;
  final int quizzesCompleted;
  final int streak;

  const StatsSection({
    super.key,
    required this.totalScore,
    required this.quizzesCompleted,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          StatCard(
            title: 'Total Score',
            value: totalScore.toString(),
            icon: Icons.star,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 15),

          StatCard(
            title: 'Quizzes Done',
            value: quizzesCompleted.toString(),
            icon: Icons.check_circle,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 15),

          StatCard(
            title: 'Day Streak',
            value: '$streak ',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), //
              // color: Color.w,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
