import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_service_marketplace/controllers/leader_board_controller.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          );
        }

        if (controller.users.isEmpty) {
          return _buildEmptyState(controller);
        }

        final users = controller.users;
        final topThree = users.take(3).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;
            final isTablet = constraints.maxWidth > 600;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeaderPodium(
                    topThree,
                    controller,
                    isSmallScreen: isSmallScreen,
                    isTablet: isTablet,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTablet ? 40 : 25,
                      isSmallScreen ? 20 : 25,
                      isTablet ? 40 : 25,
                      10,
                    ),
                    child: const Text(
                      "Global Rankings",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = users[index];
                      final rank = index + 1;
                      return _buildLeaderboardItem(
                        user,
                        rank,
                        controller,
                        isSmallScreen: isSmallScreen,
                        isTablet: isTablet,
                      );
                    }, childCount: users.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        );
      }),
    );
  }

  // PODIUM HEADER
  Widget _buildHeaderPodium(
    List<Map<String, dynamic>> topThree,
    LeaderboardController controller, {
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    final double rank1Size = isSmallScreen ? 80 : (isTablet ? 120 : 100);
    final double rank2Size = isSmallScreen ? 60 : (isTablet ? 90 : 75);
    final double rank3Size = isSmallScreen ? 50 : (isTablet ? 75 : 65);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        isTablet ? 40 : 20,
        isSmallScreen ? 25 : 35,
        isTablet ? 40 : 20,
        40,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Leaderboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 20 : 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length > 1)
                _podiumUser(
                  topThree[1],
                  2,
                  rank2Size,
                  isSmallScreen: isSmallScreen,
                ),
              SizedBox(width: isSmallScreen ? 10 : 15),
              if (topThree.isNotEmpty)
                _podiumUser(
                  topThree[0],
                  1,
                  rank1Size,
                  isSmallScreen: isSmallScreen,
                ),
              SizedBox(width: isSmallScreen ? 10 : 15),
              if (topThree.length > 2)
                _podiumUser(
                  topThree[2],
                  3,
                  rank3Size,
                  isSmallScreen: isSmallScreen,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumUser(
    Map<String, dynamic> user,
    int rank,
    double size, {
    required bool isSmallScreen,
  }) {
    bool isFirst = rank == 1;
    String uid = user['userId'] ?? 'default';
    String avatarUrl =
        "https://api.dicebear.com/9.x/avataaars/png?seed=$uid&backgroundColor=b6e3f4";

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFirst)
            Icon(
              Icons.workspace_premium,
              color: const Color(0xFFFFD700),
              size: isSmallScreen ? 28 : 35,
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size + 10,
                height: size + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFirst
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
              ),
              CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isFirst ? const Color(0xFFFFD700) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "#$rank",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFirst ? Colors.black : const Color(0xFF8B5CF6),
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            _truncateName(user['name'] ?? 'Unknown', isSmallScreen ? 8 : 12),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${user['totalScore']} pts",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isSmallScreen ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }

  // LIST ITEM
  Widget _buildLeaderboardItem(
    Map<String, dynamic> user,
    int rank,
    LeaderboardController controller, {
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    final bool isCurrentUser = user['userId'] == controller.currentUserId;
    String uid = user['userId'] ?? 'default';
    String avatarUrl =
        "https://api.dicebear.com/9.x/avataaars/png?seed=$uid&backgroundColor=b6e3f4";

    Color rankColor = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => const Color(0xFF9CA3AF),
    };

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFF3E8FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrentUser
            ? Border.all(color: const Color(0xFF8B5CF6), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 30 : 35,
            height: isSmallScreen ? 30 : 35,
            alignment: Alignment.center,
            decoration: rank <= 3
                ? BoxDecoration(
                    color: rankColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(
              "$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rankColor,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 10),
          CircleAvatar(
            radius: isSmallScreen ? 16 : 20,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          SizedBox(width: isSmallScreen ? 12 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? "${user['name']} (You)" : user['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 13 : 15,
                    color: isCurrentUser
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${user['quizzesCompleted']} Quizzes",
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${user['totalScore']} pts",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
              fontSize: isSmallScreen ? 13 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LeaderboardController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "No data yet. Be the first player!",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text(
              "Try Again",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateName(String name, int maxLength) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }
}
