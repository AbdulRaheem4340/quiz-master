import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/screens/home_screen.dart';
import 'package:local_service_marketplace/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
    vsync: this,
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });

    _startApp();
  }

  void _startApp() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Get.offAll(() => HomeScreen(initialUserName: user.displayName));
      } else {
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'QuizMaster',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
