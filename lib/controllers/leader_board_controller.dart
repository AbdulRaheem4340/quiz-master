import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_service.dart';

class LeaderboardController extends GetxController {
  final FirebaseService _firebase = FirebaseService();

  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  ///  Refresh leaderboard data
  @override
  Future<void> refresh() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final result = await _firebase.getLeaderboard();
      users.value = result;
    } catch (e) {
      debugPrint('❌ Leaderboard Error: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  String? get currentUserId => _firebase.userId;
}