import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/Fire_base_service/firebase_auth_service.dart';
import 'package:local_service_marketplace/screens/auth/login_screen.dart';
import 'package:local_service_marketplace/screens/home_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  ///  Login with Email/Password
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await _authService.loginWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar('Login Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  ///  Register with Email/Password
  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await _authService.registerWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
      );

      Get.offAll(() => HomeScreen(initialUserName: nameController.text.trim()));
    } catch (e) {
      Get.snackbar('Registration Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  ///  Login with Google
  Future<void> loginWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final credential = await _authService.signInWithGoogle();

      if (credential != null) {
        Get.offAll(() => HomeScreen(initialUserName: credential.user?.displayName));
      }
    } catch (e) {
      Get.snackbar('Google Sign-In Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  ///  Logout
  Future<void> logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      Get.offAll(() => const LoginScreen());
    }
  }

    /// Send Password Reset Email
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      Get.snackbar('Success', 'Password reset email sent!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

///  Clear all input fields
void clearFields() {
  emailController.clear();
  passwordController.clear();
  nameController.clear();
  obscurePassword.value = true;
  isLoading.value = false;
}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}