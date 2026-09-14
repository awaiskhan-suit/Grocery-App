import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grocery/home/profile.dart';
import 'categories_screen.dart';
import 'favorites.dart';
import 'product_detail_screen.dart';
import 'shopping_cart.dart';

// Import Provider classes
import 'product_provider.dart';
import 'fruit_provider.dart';

// ======================================================
// PERSISTENT FAVORITES STORAGE HELPER (Restored for legacy compatibility)
// ======================================================
class FavoriteStorage {
  static const String _keyFavorites = 'saved_favorites';

  static Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsJson = favoriteItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();
    await prefs.setStringList(_keyFavorites, favsJson);
  }

  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedFavsJson = prefs.getStringList(_keyFavorites) ?? [];
    favoriteItems.clear();
    for (String itemString in savedFavsJson) {
      try {
        final Map<String, dynamic> itemMap = jsonDecode(itemString);
        if (itemMap['id'] != null) {
          favoriteItems.add(itemMap);
        }
      } catch (e) {
        debugPrint('Failed to decode favorite item: $e');
      }
    }
  }
}

// ======================================================
// PRODUCT MODEL + GLOBAL LIST (Restored to fix other files)
// ======================================================
class Product {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String imagePath;
  final bool isNetwork;
  bool isFavorite;
  final String? badge;
  int quantity;
  bool inCart;

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    required this.isNetwork,
    required this.isFavorite,
    this.badge,
    required this.quantity,
    this.inCart = false,
  });
}

List<Product> products = [
  Product(
    id: 'f1',
    title: 'Fresh Peach',
    subtitle: 'dozen',
    price: '\$8.00',
    imagePath: 'assets/images/peach.jpg',
    isNetwork: false,
    isFavorite: false,
    badge: null,
    quantity: 1,
  ),
  Product(
    id: 'f2',
    title: 'Avocado',
    subtitle: '2.0 lbs',
    price: '\$7.00',
    imagePath: 'assets/images/Avocado.jpg',
    isNetwork: false,
    isFavorite: false,
    badge: 'NEW',
    quantity: 1,
  ),
  Product(
    id: 'f3',
    title: 'Pineapple',
    subtitle: '1.50 lbs',
    price: '\$9.90',
    imagePath: 'assets/images/pinaple.jpg',
    isNetwork: false,
    isFavorite: false,
    badge: null,
    quantity: 1,
  ),
  Product(
    id: 'f4',
    title: 'Grapes',
    subtitle: '5.0 lbs',
    price: '\$7.05',
    imagePath: 'assets/images/grapes.png',
    isNetwork: false,
    isFavorite: false,
    badge: '-16%',
    quantity: 1,
  ),
  Product(
    id: 'v1',
    title: 'Tomato',
    subtitle: 'dozen',
    price: '\$8.00',
    imagePath: 'assets/images/tomato.png',
    isNetwork: false,
    isFavorite: false,
    badge: 'NEW',
    quantity: 1,
  ),
  Product(
    id: 'v2',
    title: 'Onion',
    subtitle: '2.0 lbs',
    price: '\$7.00',
    imagePath: 'assets/images/onion.png',
    isNetwork: false,
    isFavorite: false,
    badge: null,
    quantity: 1,
  ),
  Product(
    id: 'v3',
    title: 'Potato',
    subtitle: '1.50 lbs',
    price: '\$9.90',
    imagePath: 'assets/images/potato.png',
    isNetwork: false,
    isFavorite: false,
    badge: null,
    quantity: 1,
  ),
  Product(
    id: 'v4',
    title: 'Carrot',
    subtitle: '5.0 lbs',
    price: '\$7.05',
    imagePath: 'assets/images/carrot.png',
    isNetwork: false,
    isFavorite: false,
    badge: '-16%',
    quantity: 1,
  ),
];

// Helper function to keep global products synchronized
void syncGlobalProductsList(ProductProvider vegProv, FruitProvider fruitProv) {
  for (var p in products) {
    final vegMatch = vegProv.vegetableProducts.where((v) => v.id == p.id).firstOrNull;
    if (vegMatch != null) {
      p.isFavorite = vegMatch.isFavorite;
      p.inCart = vegMatch.inCart;
      p.quantity = vegMatch.quantity;
      continue;
    }

    final fruitMatch = fruitProv.fruitProducts.where((f) => f.id == p.id).firstOrNull;
    if (fruitMatch != null) {
      p.isFavorite = fruitMatch.isFavorite;
      p.inCart = fruitMatch.inCart;
      p.quantity = fruitMatch.quantity;
    }
  }
}

// ======================================================
// CATEGORY MODEL + LIST
// ======================================================
class Category {
  final int id;
  final String name;
  final Color color;
  final IconData icon;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

List<Category> categories = [
  Category(
    id: 0,
    name: 'Vegetables',
    color: const Color(0xFFE8F5E9),
    icon: Icons.eco_outlined,
  ),
  Category(
    id: 1,
    name: 'Fruits',
    color: const Color(0xFFFFEBEE),
    icon: Icons.apple_outlined,
  ),
  Category(
    id: 2,
    name: 'Beverages',
    color: const Color(0xFFFFF8E1),
    icon: Icons.local_drink_outlined,
  ),
  Category(
    id: 3,
    name: 'Grocery',
    color: const Color(0xFFF3E5F5),
    icon: Icons.shopping_bag_outlined,
  ),
  Category(
    id: 4,
    name: 'Edible oil',
    color: const Color(0xFFE0F7FA),
    icon: Icons.water_drop_outlined,
  ),
  Category(
    id: 5,
    name: 'Fast Food',
    color: const Color(0xFFFFF3E0),
    icon: Icons.fastfood_outlined,
  ),
  Category(
    id: 6,
    name: 'Cold Drinks',
    color: const Color(0xFFE1F5FE),
    icon: Icons.local_drink_outlined,
  ),
];

// ======================================================
// HOME SCREEN
// ======================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  final List<String> _bannerImages = [
    'assets/images/banner2.png',
    'assets/images/cap1.PNG',
    'assets/images/ca3.PNG',
    'assets/images/cap4.PNG',
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProductProvider>().loadPersistedData();
      await context.read<FruitProvider>().loadPersistedData();
      if (mounted) {
        syncGlobalProductsList(
          context.read<ProductProvider>(),
          context.read<FruitProvider>(),
        );
      }
    });

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_bannerImages.isEmpty) return;

      if (_currentBannerPage < _bannerImages.length - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }

      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _navigateToProductDetail(String productName) async {
    final selectedProduct = allProductDetails.firstWhere(
          (p) => p.name.trim().toLowerCase() == productName.trim().toLowerCase(),
      orElse: () => allProductDetails.first,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: selectedProduct),
      ),
    );

    if (mounted) {
      await context.read<ProductProvider>().loadPersistedData();
      await context.read<FruitProvider>().loadPersistedData();
      syncGlobalProductsList(
        context.read<ProductProvider>(),
        context.read<FruitProvider>(),
      );
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const ProfileScreen();
      case 2:
        return FavoritesScreen(
          onFavoriteChanged: () async {
            await context.read<ProductProvider>().loadPersistedData();
            await context.read<FruitProvider>().loadPersistedData();
            if (mounted) {
              syncGlobalProductsList(
                context.read<ProductProvider>(),
                context.read<FruitProvider>(),
              );
            }
          },
        );
      case 3:
        return const ShoppingCartScreen();
      case 0:
      default:
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search keywords..',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: Icon(Icons.tune, color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFF2F4F7),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: _bannerImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentBannerPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              _bannerImages[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.green[100],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _bannerImages.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: _currentBannerPage == index ? 18 : 6,
                          decoration: BoxDecoration(
                            color: _currentBannerPage == index
                                ? const Color(0xFF7AC142)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategorySelectionScreen(),
                          ),
                        );
                        if (mounted) {
                          await context.read<ProductProvider>().loadPersistedData();
                          await context.read<FruitProvider>().loadPersistedData();
                          syncGlobalProductsList(
                            context.read<ProductProvider>(),
                            context.read<FruitProvider>(),
                          );
                        }
                      },
                      icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryItem(
                        label: category.name,
                        color: category.color,
                        icon: category.icon,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),

                Consumer2<ProductProvider, FruitProvider>(
                  builder: (context, vegProvider, fruitProvider, child) {
                    syncGlobalProductsList(vegProvider, fruitProvider);

                    final vegProducts = vegProvider.vegetableProducts;
                    final fruitProducts = fruitProvider.fruitProducts;
                    final totalLength = vegProducts.length + fruitProducts.length;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalLength,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        if (index < fruitProducts.length) {
                          final fruit = fruitProducts[index];
                          return _ProductCard(
                            id: fruit.id,
                            title: fruit.name,
                            subtitle: fruit.weight,
                            price: '\$${fruit.price.toStringAsFixed(2)}',
                            imagePath: fruit.imagePath,
                            isNetwork: false,
                            isFavorite: fruit.isFavorite,
                            inCart: fruit.inCart,
                            quantity: fruit.quantity,
                            badge: fruit.tag.isNotEmpty ? fruit.tag : null,
                            onTap: () => _navigateToProductDetail(fruit.name),
                            onFavoriteToggle: () {
                              fruitProvider.toggleFruitFavorite(fruit);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                              _showSnackBar(
                                fruit.isFavorite
                                    ? '${fruit.name} added to favorites'
                                    : '${fruit.name} removed from favorites',
                                fruit.isFavorite ? Colors.green : Colors.redAccent,
                              );
                            },
                            onAddToCart: () {
                              fruitProvider.addFruitToCart(fruit);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                              _showSnackBar('${fruit.name} added to cart', Colors.green);
                            },
                            onIncrement: () {
                              fruitProvider.incrementFruitCartQuantity(fruit);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                            },
                            onDecrement: () {
                              final removed = fruitProvider.decrementFruitCartQuantity(fruit);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                              if (removed) {
                                _showSnackBar('${fruit.name} removed from cart', Colors.redAccent);
                              }
                            },
                          );
                        } else {
                          final vegIndex = index - fruitProducts.length;
                          final veg = vegProducts[vegIndex];
                          return _ProductCard(
                            id: veg.id,
                            title: veg.name,
                            subtitle: veg.weight,
                            price: '\$${veg.price.toStringAsFixed(2)}',
                            imagePath: veg.imagePath,
                            isNetwork: false,
                            isFavorite: veg.isFavorite,
                            inCart: veg.inCart,
                            quantity: veg.quantity,
                            badge: veg.tag.isNotEmpty ? veg.tag : null,
                            onTap: () => _navigateToProductDetail(veg.name),
                            onFavoriteToggle: () {
                              vegProvider.toggleFavorite(veg);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                              _showSnackBar(
                                veg.isFavorite
                                    ? '${veg.name} added to favorites'
                                    : '${veg.name} removed from favorites',
                                veg.isFavorite ? Colors.green : Colors.redAccent,
                              );
                            },
                            onAddToCart: () {
                              vegProvider.addToCart(veg);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                              _showSnackBar('${veg.name} added to cart', Colors.green);
                            },
                            onIncrement: () {
                              vegProvider.incrementCartQuantity(veg);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                            },
                            onDecrement: () {
                              final removed = vegProvider.decrementCartQuantity(veg);
                              syncGlobalProductsList(vegProvider, fruitProvider);
                              if (removed) {
                                _showSnackBar('${veg.name} removed from cart', Colors.redAccent);
                              }
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });
          if (_selectedIndex == 0) {
            await context.read<ProductProvider>().loadPersistedData();
            await context.read<FruitProvider>().loadPersistedData();
            if (mounted) {
              syncGlobalProductsList(
                context.read<ProductProvider>(),
                context.read<FruitProvider>(),
              );
            }
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7AC142),
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// CATEGORY ITEM WIDGET
// ======================================================
class _CategoryItem extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CategoryItem({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(icon, color: Colors.black54, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// REUSABLE PRODUCT CARD WIDGET
// ======================================================
class _ProductCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String imagePath;
  final bool isNetwork;
  final bool isFavorite;
  final bool inCart;
  final int quantity;
  final String? badge;

  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imagePath,
    required this.isNetwork,
    required this.isFavorite,
    required this.inCart,
    required this.quantity,
    this.badge,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: isNetwork
                              ? Image.network(imagePath, fit: BoxFit.contain)
                              : Image.asset(imagePath, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFF7AC142),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              SizedBox(
                height: 38,
                child: inCart
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.remove,
                        size: 16,
                        color: Color(0xFF7AC142),
                      ),
                      onPressed: onDecrement,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Color(0xFF7AC142),
                      ),
                      onPressed: onIncrement,
                    ),
                  ],
                )
                    : InkWell(
                  onTap: onAddToCart,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 14,
                        color: Color(0xFF7AC142),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Add to cart',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badge == 'NEW'
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: badge == 'NEW'
                        ? const Color(0xFFFF9800)
                        : const Color(0xFFE53935),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey[400],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}