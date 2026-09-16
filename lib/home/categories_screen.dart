import 'package:flutter/material.dart';
import 'package:grocery/home/products_screen.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import 'fruits.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int selectedIndex = 0;

  // ============================================================
  // HANDLE CATEGORY TAP
  // ============================================================

  void _onCategoryTap(BuildContext context, int index, String title) {
    setState(() {
      selectedIndex = index;
    });

    // ========== NAVIGATION LOGIC ==========
    if (title == 'Vegetables') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductsScreen()),
      );
    } else if (title == 'Fruits') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FruitsScreen()),
      );
    } else {
      // For other categories that don't have products yet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title coming soon!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            final categories = categoryProvider.categories;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () => _onCategoryTap(context, index, item.title),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: item.bgColor,
                                child: Icon(
                                  item.icon,
                                  color: item.iconColor,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}