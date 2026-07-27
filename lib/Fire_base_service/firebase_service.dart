import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import 'firebase_auth_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuthService _auth = FirebaseAuthService();

  bool get isLoggedIn => _auth.isLoggedIn;
  User? get currentUser => _auth.currentUser;
  String? get userId => _auth.userId;
  String? get userEmail => _auth.userEmail;
  String? get userName => _auth.userName;

  // CATEGORIES
  Future<List<QuizCategory>> getCategories() async {
    try {
      debugPrint('📡 Fetching categories from Firebase...');
      final snapshot = await _database.child('categories').get();

      if (!snapshot.exists) {
        debugPrint('⚠️ No categories found in database');
        return [];
      }

      final List<QuizCategory> categories = [];

      for (final child in snapshot.children) {
        final dynamic val = child.value;
        if (val == null || val is! Map) continue;

        final data = Map<String, dynamic>.from(val);
        categories.add(
          QuizCategory(
            id: int.tryParse(child.key ?? '0') ?? data['id'] ?? 0,
            name: data['name'] ?? 'Unknown',
            icon: data['icon'] ?? '❓',
            quizCount: data['quizCount'] ?? 0,
            color: _hexToColor(data['color'] ?? '#8B5CF6'),
            description: data['description'] ?? '',
          ),
        );
      }

      categories.sort((a, b) => a.id.compareTo(b.id));
      debugPrint('✅ Fetched ${categories.length} categories');
      return categories;
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      return [];
    }
  }

  Future<QuizCategory?> getCategory(int categoryId) async {
    try {
      final snapshot = await _database.child('categories/$categoryId').get();
      if (!snapshot.exists) return null;

      final dynamic val = snapshot.value;
      if (val == null || val is! Map) return null;

      final data = Map<String, dynamic>.from(val);
      return QuizCategory(
        id: categoryId,
        name: data['name'] ?? 'Unknown',
        icon: data['icon'] ?? '❓',
        quizCount: data['quizCount'] ?? 0,
        color: _hexToColor(data['color'] ?? '#8B5CF6'),
        description: data['description'] ?? '',
      );
    } catch (e) {
      debugPrint('❌ Error fetching category: $e');
      return null;
    }
  }

  // QUIZZES
  Future<List<Quiz>> getQuizzesByCategory(int categoryId) async {
    try {
      debugPrint('📡 Fetching quizzes for category $categoryId...');
      final snapshot = await _database.child('quizzes').get();

      if (!snapshot.exists) {
        debugPrint('⚠️ No quizzes found');
        return [];
      }

      final List<Quiz> quizzes = [];

      for (final child in snapshot.children) {
        final dynamic val = child.value;
        if (val == null || val is! Map) continue;

        final data = Map<String, dynamic>.from(val);

        final dbCategoryId = data['categoryId']?.toString();
        if (dbCategoryId == categoryId.toString()) {
          quizzes.add(Quiz.fromMap(data));
        }
      }

      debugPrint(
        '✅ Fetched ${quizzes.length} quizzes for category $categoryId',
      );
      return quizzes;
    } catch (e) {
      debugPrint('❌ Error fetching quizzes: $e');
      return [];
    }
  }

  Future<Quiz?> getQuiz(int quizId) async {
    try {
      final snapshot = await _database.child('quizzes/$quizId').get();
      if (!snapshot.exists) return null;

      final dynamic val = snapshot.value;
      if (val == null || val is! Map) return null;

      final data = Map<String, dynamic>.from(val);
      return Quiz(
        id: quizId,
        categoryId: data['categoryId'] ?? 0,
        title: data['title'] ?? 'Unknown',
        description: data['description'] ?? '',
        difficulty: _parseDifficulty(data['difficulty'] ?? 'medium'),
        questionCount: data['questionCount'] ?? 0,
        duration: data['duration'] ?? 0,
        totalPoints: data['totalPoints'] ?? 0,
        iconEmoji: data['iconEmoji'] ?? '📝',
      );
    } catch (e) {
      debugPrint('❌ Error fetching quiz: $e');
      return null;
    }
  }

  // QUESTIONS
  Future<List<Question>> getQuestions(int quizId) async {
    try {
      debugPrint('📡 Fetching questions for quiz $quizId...');
      final snapshot = await _database.child('questions').get();

      if (!snapshot.exists) {
        debugPrint('⚠️ No questions found');
        return [];
      }

      final List<Question> questions = [];

      for (final child in snapshot.children) {
        final dynamic val = child.value;
        if (val == null || val is! Map) continue;

        final data = Map<String, dynamic>.from(val);

        final dbQuizId = data['quizId']?.toString();
        if (dbQuizId == quizId.toString()) {
          questions.add(Question.fromMap(data));
        }
      }

      questions.sort((a, b) => a.id.compareTo(b.id));
      debugPrint('✅ Fetched ${questions.length} questions for quiz $quizId');
      return questions;
    } catch (e) {
      debugPrint('❌ Error fetching questions: $e');
      return [];
    }
  }

  // HISTORY NAMES
  Future<void> submitQuizResult({
    required int quizId,
    required int categoryId,
    required String quizTitle,
    required String categoryName,
    required int score,
    required int totalScore,
    required int correctAnswers,
    required int totalQuestions,
    required int timeTaken,
  }) async {
    try {
      if (!isLoggedIn) return;
      final uid = userId!;

      await _database.child('results').child(uid).push().set({
        'quizId': quizId,
        'quizTitle': quizTitle,
        'categoryId': categoryId,
        'score': score,
        'percentage': (score / totalScore) * 100,
        'completedAt': ServerValue.timestamp,
      });

      final userSnap = await _database.child('users').child(uid).get();

      int oldScore =
          int.tryParse(userSnap.child('totalScore').value?.toString() ?? '0') ??
          0;
      int oldQuizzes =
          int.tryParse(
            userSnap.child('quizzesCompleted').value?.toString() ?? '0',
          ) ??
          0;
      int currentStreak =
          int.tryParse(userSnap.child('streak').value?.toString() ?? '0') ?? 0;
      String name =
          userSnap.child('name').value?.toString() ?? userName ?? 'User';
      String avatar = userSnap.child('avatar').value?.toString() ?? '';

      String? lastPlayedDateStr = userSnap
          .child('lastPlayedDate')
          .value
          ?.toString();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int newStreak = currentStreak;

      if (lastPlayedDateStr == null) {
        newStreak = 1; 
      } else {
        try {
          final lastPlayed = DateTime.parse(lastPlayedDateStr);
          final lastDate = DateTime(
            lastPlayed.year,
            lastPlayed.month,
            lastPlayed.day,
          );

          final difference = today.difference(lastDate).inDays;

          if (difference == 1) {
            newStreak++;
          } else if (difference > 1) {
            newStreak = 1;
          }
        } catch (e) {
          newStreak = 1;
        }
      }

      final Map<String, dynamic> updates = {};

      updates['users/$uid/totalScore'] = oldScore + score;
      updates['users/$uid/quizzesCompleted'] = oldQuizzes + 1;
      updates['users/$uid/streak'] = newStreak;
      updates['users/$uid/lastPlayedDate'] = now.toIso8601String(); //
      updates['users/$uid/updatedAt'] = ServerValue.timestamp;

      updates['leaderboard/$uid'] = {
        'name': name,
        'avatar': avatar,
        'totalScore': oldScore + score,
        'quizzesCompleted': oldQuizzes + 1,
        'streak': newStreak,
        'updatedAt': ServerValue.timestamp,
      };

      await _database.update(updates);
    } catch (e) {
      debugPrint('❌ Error submitting result: $e');
    }
  }

  //  LEADERBOARD
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      debugPrint('📡 Fetching leaderboard data...');
      final snapshot = await _database.child('leaderboard').get();

      if (!snapshot.exists) {
        debugPrint('⚠️ Leaderboard node does not exist in Firebase');
        return [];
      }

      final List<Map<String, dynamic>> leaderboardList = [];

      for (final child in snapshot.children) {
        try {
          final String name =
              child.child('name').value?.toString() ?? 'Unknown';
          final String avatar = child.child('avatar').value?.toString() ?? '';
          final int score =
              int.tryParse(
                child.child('totalScore').value?.toString() ?? '0',
              ) ??
              0;
          final int quizzes =
              int.tryParse(
                child.child('quizzesCompleted').value?.toString() ?? '0',
              ) ??
              0;

          leaderboardList.add({
            'userId': child.key,
            'name': name,
            'avatar': avatar,
            'totalScore': score,
            'quizzesCompleted': quizzes,
          });
        } catch (e) {
          debugPrint("❌ Error parsing user ${child.key}: $e");
        }
      }

      leaderboardList.sort(
        (a, b) => (b['totalScore'] as int).compareTo(a['totalScore'] as int),
      );

      // Assign ranks
      for (int i = 0; i < leaderboardList.length; i++) {
        leaderboardList[i]['rank'] = i + 1;
      }

      debugPrint('✅ Successfully fetched ${leaderboardList.length} users');
      return leaderboardList;
    } catch (e) {
      debugPrint('❌ Critical Leaderboard Error: $e');
      return [];
    }
  }

  // ADD this method inside your FirebaseService class

Future<void> resetPlayedQuizIds(int categoryId) async {
  try {
    if (!isLoggedIn) return;

    final uid = userId!;

    // Get all results for this user
    final snapshot = await _database
        .child('results')
        .child(uid)
        .get();

    if (!snapshot.exists) return;

    // Find all result keys that belong to this category
    List<String> keysToDelete = [];

    for (final child in snapshot.children) {
      final dbCatId = child.child('categoryId').value?.toString();
      if (dbCatId == categoryId.toString()) {
        keysToDelete.add(child.key!);
      }
    }

    // Delete all results for this category
    for (final key in keysToDelete) {
      await _database
          .child('results')
          .child(uid)
          .child(key)
          .remove();
    }

    debugPrint(
      '✅ Reset ${keysToDelete.length} results for category $categoryId',
    );
  } catch (e) {
    debugPrint('❌ Error resetting played quiz ids: $e');
  }
}

  // USER HISTORY
  Future<List<Map<String, dynamic>>> getUserHistory() async {
    try {
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in');
        return [];
      }

      final DatabaseEvent event = await _database
          .child('results')
          .child(userId!)
          .orderByChild('completedAt')
          .limitToLast(50)
          .once();

      final snapshot = event.snapshot;

      if (!snapshot.exists || snapshot.value == null) {
        debugPrint('⚠️ No history found');
        return [];
      }

      final List<Map<String, dynamic>> history = [];
      final dynamic data = snapshot.value;

      if (data is Map) {
        data.forEach((key, value) {
          if (value is! Map) return;
          try {
            final entry = Map<String, dynamic>.from(value);
            entry['id'] = key.toString();
            history.add(entry);
          } catch (e) {
            debugPrint('❌ Error parsing history entry $key: $e');
          }
        });
      } else if (data is List) {
        for (int i = 0; i < data.length; i++) {
          final value = data[i];
          if (value == null || value is! Map) continue;
          try {
            final entry = Map<String, dynamic>.from(value);
            entry['id'] = i.toString();
            history.add(entry);
          } catch (e) {
            debugPrint('❌ Error parsing history entry $i: $e');
          }
        }
      }

      history.sort((a, b) {
        final aTime = a['completedAt'] ?? 0;
        final bTime = b['completedAt'] ?? 0;
        return bTime.compareTo(aTime);
      });

      debugPrint('✅ Fetched ${history.length} history items');
      return history;
    } catch (e) {
      debugPrint('❌ Error fetching history: $e');
      return [];
    }
  }

  // USER STATS
  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      if (!isLoggedIn) return null;

      final DatabaseEvent event = await _database
          .child('users')
          .child(userId!)
          .once();
      final snapshot = event.snapshot;

      if (!snapshot.exists || snapshot.value == null) return null;

      final dynamic data = snapshot.value;
      if (data is! Map) return null;

      final userData = Map<String, dynamic>.from(data);

      return {
        'name': userData['name'] ?? 'User',
        'email': userData['email'] ?? '',
        'avatar': userData['avatar'] ?? '👤',
        'totalScore':
            int.tryParse(userData['totalScore']?.toString() ?? '0') ?? 0,
        'quizzesCompleted':
            int.tryParse(userData['quizzesCompleted']?.toString() ?? '0') ?? 0,
        'rank': int.tryParse(userData['rank']?.toString() ?? '0') ?? 0,
        'streak': int.tryParse(userData['streak']?.toString() ?? '0') ?? 0,
      };
    } catch (e) {
      debugPrint('❌ Error fetching user stats: $e');
      return null;
    }
  }

  // HELPER METHODS
  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  QuizDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return QuizDifficulty.easy;
      case 'hard':
        return QuizDifficulty.hard;
      default:
        return QuizDifficulty.medium;
    }
  }

  // Clean method
  Future<void> emergencyCleanup() async {
    try {
      debugPrint('🧹 Starting emergency cleanup...');

      final usersEvent = await _database.child('users').once();
      final usersSnapshot = usersEvent.snapshot;

      if (usersSnapshot.exists && usersSnapshot.value is Map) {
        final data = usersSnapshot.value as Map;
        data.forEach((key, value) async {
          if (value is! Map) {
            debugPrint('🔴 Deleting corrupted user: $key');
            await _database.child('users').child(key.toString()).remove();
          }
        });
      }

      // Clean leaderboard
      final leaderboardEvent = await _database.child('leaderboard').once();
      final leaderboardSnapshot = leaderboardEvent.snapshot;

      if (leaderboardSnapshot.exists && leaderboardSnapshot.value is Map) {
        final data = leaderboardSnapshot.value as Map;
        data.forEach((key, value) async {
          if (value is! Map) {
            debugPrint('🔴 Deleting corrupted leaderboard entry: $key');
            await _database.child('leaderboard').child(key.toString()).remove();
          }
        });
      }

      debugPrint('✅ Emergency cleanup complete');
    } catch (e) {
      debugPrint('❌ Cleanup error: $e');
    }
  }

  Future<List<int>> getPlayedQuizIds(int categoryId) async {
    try {
      if (!isLoggedIn) return [];

      final snapshot = await _database.child('results').child(userId!).get();
      if (!snapshot.exists) return [];

      Set<int> playedIds = {};

      for (final child in snapshot.children) {
        final dbCatId = child.child('categoryId').value?.toString();
        if (dbCatId == categoryId.toString()) {
          final qId = int.tryParse(
            child.child('quizId').value?.toString() ?? '0',
          );
          if (qId != null && qId != 0) {
            playedIds.add(qId);
          }
        }
      }
      return playedIds.toList();
    } catch (e) {
      debugPrint('❌ Error fetching played quizzes: $e');
      return [];
    }
  }

  // GET ALL QUIZZES (For Explore Screen)
  Future<List<Quiz>> getAllQuizzes() async {
    try {
      debugPrint('📡 Fetching ALL quizzes for Explore...');
      final snapshot = await _database.child('quizzes').get();

      if (!snapshot.exists) return [];

      final List<Quiz> quizzes = [];
      for (final child in snapshot.children) {
        if (child.value is Map) {
          final data = Map<String, dynamic>.from(child.value as Map);
          quizzes.add(Quiz.fromMap(data));
        }
      }

      quizzes.shuffle();
      debugPrint('✅ Fetched ${quizzes.length} quizzes for Explore');
      return quizzes;
    } catch (e) {
      debugPrint('❌ Error fetching all quizzes: $e');
      return [];
    }
  }
}
