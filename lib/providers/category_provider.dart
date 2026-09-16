import 'package:flutter/material.dart';

class CategoryItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  CategoryItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class CategoryProvider extends ChangeNotifier {
  final List<CategoryItem> _categories = [
    CategoryItem(
      title: 'Vegetables',
      icon: Icons.eco_outlined,
      iconColor: const Color(0xFF2E7D32),
      bgColor: const Color(0xFFE8F5E9),
    ),
    CategoryItem(
      title: 'Fruits',
      icon: Icons.apple,
      iconColor: const Color(0xFFE65100),
      bgColor: const Color(0xFFFFF3E0),
    ),
    CategoryItem(
      title: 'Beverages',
      icon: Icons.local_drink_outlined,
      iconColor: const Color(0xFF0277BD),
      bgColor: const Color(0xFFE1F5FE),
    ),
    CategoryItem(
      title: 'Grocery',
      icon: Icons.shopping_bag_outlined,
      iconColor: const Color(0xFFC2185B),
      bgColor: const Color(0xFFFCE4EC),
    ),
    CategoryItem(
      title: 'Edible Oil',
      icon: Icons.opacity_outlined,
      iconColor: const Color(0xFFF57F17),
      bgColor: const Color(0xFFFFFDE7),
    ),
    CategoryItem(
      title: 'Household',
      icon: Icons.clean_hands_outlined,
      iconColor: const Color(0xFF512DA8),
      bgColor: const Color(0xFFEDE7F6),
    ),
    CategoryItem(
      title: 'Fast Food',
      icon: Icons.fastfood_outlined,
      iconColor: const Color(0xFFF57F17),
      bgColor: const Color(0xFFFFF3E0),
    ),
    CategoryItem(
      title: 'Cold Drinks',
      icon: Icons.local_drink_outlined,
      iconColor: const Color(0xFF2E7D32),
      bgColor: const Color(0xFFE8F5E9),
    ),
    CategoryItem(
      title: 'Biryani',
      icon: Icons.rice_bowl_outlined,
      iconColor: const Color(0xFF0277BD),
      bgColor: const Color(0xFFFFF3E0),
    ),
  ];

  // ======================================================
  // GETTERS
  // ======================================================

  List<CategoryItem> get categories => List.unmodifiable(_categories);

  int get categoryCount => _categories.length;

  // ======================================================
  // FIND CATEGORY BY TITLE
  // ======================================================

  CategoryItem? getCategoryByTitle(String title) {
    try {
      return _categories.firstWhere(
            (category) => category.title.toLowerCase() == title.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ======================================================
  // GET CATEGORY INDEX
  // ======================================================

  int getCategoryIndex(String title) {
    return _categories.indexWhere(
          (category) => category.title.toLowerCase() == title.toLowerCase(),
    );
  }
}

