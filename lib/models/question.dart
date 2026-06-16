class Question {
  final int id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final int points;
  int? selectedAnswerIndex;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.points = 10,
    this.selectedAnswerIndex,
  });

  // ✅ THIS FACTORY IS REQUIRED
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? 0,
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      explanation: map['explanation'],
      points: map['points'] ?? 10,
    );
  }

  bool get isAnswered => selectedAnswerIndex != null;
  bool get isCorrect => selectedAnswerIndex == correctAnswerIndex;
  String get correctAnswer => options[correctAnswerIndex];
  String? get selectedAnswer => selectedAnswerIndex != null ? options[selectedAnswerIndex!] : null;
}