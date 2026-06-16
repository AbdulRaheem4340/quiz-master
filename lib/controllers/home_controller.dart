import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_service.dart';
import 'package:local_service_marketplace/models/category.dart';

class HomeController extends GetxController {
  final FirebaseService _firebase = FirebaseService();

 
  // Bottom Navigation
  final RxInt currentIndex = 0.obs;

  // Categories
  final RxList<QuizCategory> categories = <QuizCategory>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // User Stats
  final RxString userName = 'User'.obs;
  final RxInt totalScore = 0.obs;
  final RxInt quizzesCompleted = 0.obs;
  final RxInt streak = 0.obs;

  // Initial username (passed from Login/Signup screen)
  String? initialUserName;

  @override
  void onInit() {
    super.onInit();
    if (initialUserName != null) {
      userName.value = initialUserName!;
    }
    loadHomeData();
  }

  ///  Load all home data (categories + user stats)
  Future<void> loadHomeData() async {
    isLoading.value = true;
    await Future.wait([loadCategories(), loadUserData()]);
    isLoading.value = false;
  }

  ///  Load Categories from Firebase
  Future<void> loadCategories() async {
    try {
      final result = await _firebase.getCategories();
      categories.value = result;
      hasError.value = false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('❌ Error loading categories: $e');
    }
  }

  ///  Load User Stats (Name, Score, Streak)
  Future<void> loadUserData() async {
    if (!_firebase.isLoggedIn) return;

    try {
      final stats = await _firebase.getUserStats();
      if (stats != null) {
        userName.value = stats['name'] ?? 'User';
        totalScore.value = int.tryParse(stats['totalScore'].toString()) ?? 0;
        quizzesCompleted.value = int.tryParse(stats['quizzesCompleted'].toString()) ?? 0;
        streak.value = int.tryParse(stats['streak'].toString()) ?? 0;
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
    }
  }

  Future<void> refreshUserData() async {
    await loadUserData();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}