import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

class CategoriesProvider extends ChangeNotifier {
  final List<CategoryItem> _categories = const [
    CategoryItem(
      id: 'c1',
      title: 'Vegetables',
      icon: Icons.eco_outlined,
      iconColor: Color(0xFF2E7D32),
      bgColor: Color(0xFFE8F5E9),
    ),
    CategoryItem(
      id: 'c2',
      title: 'Fruits',
      icon: Icons.apple,
      iconColor: Color(0xFFE65100),
      bgColor: Color(0xFFFFF3E0),
    ),
    CategoryItem(
      id: 'c3',
      title: 'Beverages',
      icon: Icons.local_drink_outlined,
      iconColor: Color(0xFF0277BD),
      bgColor: Color(0xFFE1F5FE),
    ),
    CategoryItem(
      id: 'c4',
      title: 'Grocery',
      icon: Icons.shopping_bag_outlined,
      iconColor: Color(0xFFC2185B),
      bgColor: Color(0xFFFCE4EC),
    ),
    CategoryItem(
      id: 'c5',
      title: 'Edible Oil',
      icon: Icons.opacity_outlined,
      iconColor: Color(0xFFF57F17),
      bgColor: Color(0xFFFFFDE7),
    ),
    CategoryItem(
      id: 'c6',
      title: 'Household',
      icon: Icons.clean_hands_outlined,
      iconColor: Color(0xFF512DA8),
      bgColor: Color(0xFFEDE7F6),
    ),
    CategoryItem(
      id: 'c7',
      title: 'Fast Food',
      icon: Icons.fastfood_outlined,
      iconColor: Color(0xFFF57F17),
      bgColor: Color(0xFFFFF3E0),
    ),
    CategoryItem(
      id: 'c8',
      title: 'Cold Drinks',
      icon: Icons.local_drink_outlined,
      iconColor: Color(0xFF2E7D32),
      bgColor: Color(0xFFE8F5E9),
    ),
    CategoryItem(
      id: 'c9',
      title: 'Biryani',
      icon: Icons.rice_bowl_outlined,
      iconColor: Color(0xFF0277BD),
      bgColor: Color(0xFFFFF3E0),
    ),
  ];

  CategoriesProvider(int categoryId);

  List<CategoryItem> get categories => _categories;

  int get categoryCount => _categories.length;

  CategoryItem? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  CategoryItem? getCategoryByTitle(String title) {
    try {
      return _categories.firstWhere(
            (category) => category.title.toLowerCase() == title.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}