import 'package:flutter/material.dart';
import '../categories/fruits_screen.dart';
import '../categories/vegetables_screen.dart';


class CategoryScreenDashboard extends StatelessWidget {
  const CategoryScreenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Vegetables',
        'icon': Icons.eco_outlined,
        'color': const Color(0xFFE8F5E9),
        'iconColor': const Color(0xFF4CAF50),
        'screen': const VegetablesScreen(),
      },
      {
        'title': 'Fruits',
        'icon': Icons.apple,
        'color': const Color(0xFFFFF3E0),
        'iconColor': const Color(0xFFFF9800),
        'screen': const FruitsScreen(),
      },
      {
        'title': 'Beverages',
        'icon': Icons.local_drink_outlined,
        'color': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF2196F3),
        'screen': null,
      },
      {
        'title': 'Grocery',
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFFF3E5F5),
        'iconColor': const Color(0xFF9C27B0),
        'screen': null,
      },
      {
        'title': 'Edible Oil',
        'icon': Icons.water_drop_outlined,
        'color': const Color(0xFFFFF8E1),
        'iconColor': const Color(0xFFFFC107),
        'screen': null,
      },
      {
        'title': 'Household',
        'icon': Icons.home_outlined,
        'color': const Color(0xFFE0F7FA),
        'iconColor': const Color(0xFF00BCD4),
        'screen': null,
      },
      {
        'title': 'Fast Food',
        'icon': Icons.fastfood_outlined,
        'color': const Color(0xFFFFEBEE),
        'iconColor': const Color(0xFFF44336),
        'screen': null,
      },
      {
        'title': 'Cold Drinks',
        'icon': Icons.local_cafe_outlined,
        'color': const Color(0xFFE8F5E9),
        'iconColor': const Color(0xFF4CAF50),
        'screen': null,
      },
      {
        'title': 'Biryani',
        'icon': Icons.restaurant_outlined,
        'color': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF2196F3),
        'screen': null,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7AC142),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final bool hasScreen = category['screen'] != null;

            return GestureDetector(
              onTap: () {
                if (hasScreen) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => category['screen'] as Widget,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${category['title']} coming soon!'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: hasScreen
                      ? Border.all(
                    color: const Color(0xFF7AC142),
                    width: 1.5,
                  )
                      : null,
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
                      backgroundColor: category['color'] as Color,
                      child: Icon(
                        category['icon'] as IconData,
                        color: category['iconColor'] as Color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}