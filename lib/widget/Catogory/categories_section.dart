import 'package:flutter/material.dart';
import 'package:local_service_marketplace/models/category.dart';
import 'package:local_service_marketplace/widget/Catogory/category_card_widget.dart';
import '../Home/section_header.dart';
import '../Home/loading_grid.dart';
import '../Home/error_widget.dart';

class CategoriesSection extends StatelessWidget {
  final List<QuizCategory> categories;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final Function(QuizCategory) onCategoryTap;
  final VoidCallback onRetry;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.onCategoryTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingGrid();
    }

    if (hasError) {
      return ErrorDisplay(errorMessage: errorMessage, onRetry: onRetry);
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Categories',
            subtitle: 'Choose a topic',
            onSeeAll: () {
              // Navigate to all categories
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.79,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return CategoryGridItem(
                category: categories[index],
                index: index,
                onTap: () => onCategoryTap(categories[index]),
              );
            }, childCount: categories.length),
          ),
        ),
      ],
    );
  }
}

class CategoryGridItem extends StatefulWidget {
  final QuizCategory category;
  final int index;
  final VoidCallback onTap;

  const CategoryGridItem({
    super.key,
    required this.category,
    required this.index,
    required this.onTap,
  });

  @override
  State<CategoryGridItem> createState() => _CategoryGridItemState();
}

class _CategoryGridItemState extends State<CategoryGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset(0, 0.3 + (widget.index * 0.1)),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CategoryCard(category: widget.category, onTap: widget.onTap),
      ),
    );
  }
}
