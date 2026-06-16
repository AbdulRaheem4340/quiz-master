import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_auth_service.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_service.dart';
import 'package:local_service_marketplace/screens/auth/login_screen.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebase = FirebaseService();
  final FirebaseAuthService _auth = FirebaseAuthService();

  final Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> history = <Map<String, dynamic>>[].obs;
  final RxBool isHistoryLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadHistory();
  }

  ///  Load User Stats
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final data = await _firebase.getUserStats();
      userData.value = data;
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  ///  Load Quiz History
  Future<void> loadHistory() async {
    try {
      isHistoryLoading.value = true;
      final result = await _firebase.getUserHistory();
      history.value = result;
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  ///  Logout with confirmation
  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _auth.logout();
    Get.offAll(() => const LoginScreen());
  }

  /// Getters
  String get userEmail => _auth.userEmail ?? '';
  String get userId => _auth.userId ?? 'default';
  String get userName => userData.value?['name'] ?? 'User';
  String get avatarUrl =>
      "https://api.dicebear.com/9.x/avataaars/png?seed=$userId&backgroundColor=b6e3f4";

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(dt.year, dt.month, dt.day);
      final difference = today.difference(dateOnly).inDays;

      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final time = '$hour:$minute $amPm';

      if (difference == 0) return 'Today • $time';
      if (difference == 1) return 'Yesterday • $time';
      if (difference < 7) return '$difference days ago • $time';

      return '${dt.day}/${dt.month}/${dt.year} • $time';
    } catch (e) {
      return 'Recently';
    }
  }
}
