import 'package:flutter/material.dart';
import 'fruits.dart';
import 'products_screen.dart'; // ← Make sure this file exists

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

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int selectedIndex = 0;

  final List<CategoryItem> categories = [
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
      bgColor: const Color(0xFFEDE7F6),
    ),


    CategoryItem(
      title: 'Cold Drinks',
      icon: Icons.local_drink_outlined,
      iconColor: const Color(0xFF2E7D32),
      bgColor: const Color(0xFFEDE7F6),
    ),
    CategoryItem(
      title: 'Biryani',
      icon: Icons.rice_bowl_outlined,
      iconColor: const Color(0xFF0277BD), // Deep warm orange
      bgColor: const Color(0xFFFFF3E0),   // Soft light orange background
    ),

  ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });

                      // ========== NAVIGATION LOGIC ==========
                      if (item.title == 'Vegetables') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductsScreen(),
                          ),
                        );
                      }
                      // You can add more conditions later for other categories
                       else if (item.title == 'Fruits') {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FruitsScreen(),
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.transparent,
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
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.green : Colors.black87,
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
        ),
      ),
    );
  }
}