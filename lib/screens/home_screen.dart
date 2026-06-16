import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/controllers/home_controller.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/screens/bottom_app_bar_Screen/explore_screen.dart';
import 'package:local_service_marketplace/screens/bottom_app_bar_Screen/leader_board_screen.dart';
import 'package:local_service_marketplace/screens/bottom_app_bar_Screen/profile_screen.dart';
import 'package:local_service_marketplace/screens/quiz_list_screen.dart';
import 'package:local_service_marketplace/widget/Catogory/categories_section.dart';
import 'package:local_service_marketplace/widget/Catogory/custom_bot_nav_bar.dart';
import 'package:local_service_marketplace/widget/Home/home_app_bar.dart';
import 'package:local_service_marketplace/widget/Home/stats_section.dart';
import 'package:local_service_marketplace/widget/Home/welcome_section.dart';

class HomeScreen extends StatelessWidget {
  final String? initialUserName;

  const HomeScreen({super.key, this.initialUserName});

  @override
  Widget build(BuildContext context) {
      SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final controller = Get.put(
      HomeController()..initialUserName = initialUserName,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: [
              _buildHomeTab(controller),

              // Tab 1: Explore
              const ExploreScreen(),

              // Tab 2: Leaderboard
              const LeaderboardScreen(),

              // Tab 3: Profile
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }

  Widget _buildHomeTab(HomeController controller) {
    return RefreshIndicator(
      onRefresh: controller.loadHomeData,
      color: const Color(0xFF8B5CF6),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: HomeAppBar()),

          SliverToBoxAdapter(
            child: Obx(
              () => WelcomeSection(userName: controller.userName.value),
            ),
          ),

          SliverToBoxAdapter(
            child: Obx(
              () => StatsSection(
                totalScore: controller.totalScore.value,
                quizzesCompleted: controller.quizzesCompleted.value,
                streak: controller.streak.value,
              ),
            ),
          ),

          //  Categories Section reacts to category list changes
          Obx(
            () => CategoriesSection(
              categories: controller.categories,
              isLoading: controller.isLoading.value,
              hasError: controller.hasError.value,
              errorMessage: controller.errorMessage.value,
              onCategoryTap: (category) =>
                  _navigateToQuizList(category, controller),
              onRetry: controller.loadHomeData,
            ),
          ),
        ],
      ),
    );
  }

  ///  Navigate to Quiz List and refresh data when returning
  void _navigateToQuizList(
    QuizCategory category,
    HomeController controller,
  ) async {
    await Get.to(() => QuizListScreen(category: category));
    controller.refreshUserData();
  }
}
