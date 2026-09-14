import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery/home/profile.dart';
import 'categories_screen.dart';
import 'favorites.dart';
import 'product_detail_screen.dart';
import 'shopping_cart.dart';

// ======================================================
// PERSISTENT FAVORITES STORAGE HELPER
// ======================================================
class FavoriteStorage {
  static const String _keyFavorites = 'saved_favorites';

  /// Save list of favorited product items to SharedPreferences
  static Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsJson = favoriteItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();
    await prefs.setStringList(_keyFavorites, favsJson);
  }

  /// Load saved favorited products from SharedPreferences safely
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
// PRODUCT MODEL + LIST
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
    id: 'h0',
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
    id: 'h1',
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
    id: 'h2',
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
    id: 'h3',
    title: 'Pomegranate',
    subtitle: '1.50 lbs',
    price: '\$2.09',
    imagePath:
    'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?q=80&w=600&auto=format&fit=crop',
    isNetwork: true,
    isFavorite: false,
    badge: 'NEW',
    quantity: 1,
  ),
  Product(
    id: 'h4',
    title: 'Fresh Broccoli',
    subtitle: '1 kg',
    price: '\$3.00',
    imagePath:
    'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?q=80&w=600&auto=format&fit=crop',
    isNetwork: true,
    isFavorite: false,
    badge: null,
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
    _initPersistentData();

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

  Future<void> _initPersistentData() async {
    await FavoriteStorage.loadFavorites();
    await CartStorage.loadCart();
    _syncProductsWithFavorites();
  }

  /// Strictly sync product favorite flags & cart state against unique string IDs
  void _syncProductsWithFavorites() {
    final Set<String> favoriteIds = favoriteItems
        .where((item) => item['id'] != null)
        .map((item) => item['id'].toString())
        .toSet();

    final Set<String> cartIds = cartItems
        .where((item) => item['id'] != null)
        .map((item) => item['id'].toString())
        .toSet();

    setState(() {
      for (var p in products) {
        p.isFavorite = favoriteIds.contains(p.id.toString());

        p.inCart = cartIds.contains(p.id.toString());
        if (p.inCart) {
          final cartItem = cartItems.firstWhere(
                (item) => item['id'].toString() == p.id.toString(),
          );
          p.quantity = cartItem['quantity'] ?? 1;
        } else {
          p.quantity = 1;
        }
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String productId) {
    setState(() {
      final product = products.firstWhere((p) => p.id == productId);
      product.isFavorite = !product.isFavorite;

      if (product.isFavorite) {
        final bool exists = favoriteItems.any(
              (item) => item['id']?.toString() == product.id,
        );

        if (!exists) {
          favoriteItems.add({
            'id': product.id,
            'title': product.title,
            'unit': product.subtitle,
            'price': product.price,
            'imagePath': product.imagePath,
            'bgColor': Colors.grey[100],
          });
        }
        _showSnackBar('${product.title} added to favorites', Colors.green);
      } else {
        favoriteItems.removeWhere(
              (item) => item['id']?.toString() == product.id,
        );
        _showSnackBar(
          '${product.title} removed from favorites',
          Colors.redAccent,
        );
      }
    });

    FavoriteStorage.saveFavorites();
  }

  void _syncToCart(Product product) {
    final existingIndex = cartItems.indexWhere(
          (item) => item['id']?.toString() == product.id,
    );

    final double numericPrice =
        double.tryParse(product.price.replaceAll('\$', '')) ?? 0.0;

    if (product.inCart) {
      final cartData = {
        'id': product.id,
        'title': product.title,
        'unitPrice': numericPrice,
        'price': '${product.price} x ${product.quantity}',
        'unit': product.subtitle,
        'quantity': product.quantity,
        'imagePath': product.imagePath,
        'bgColor': Colors.grey[100],
      };

      if (existingIndex >= 0) {
        cartItems[existingIndex] = cartData;
      } else {
        cartItems.add(cartData);
      }
    } else {
      if (existingIndex >= 0) {
        cartItems.removeAt(existingIndex);
      }
    }

    // Persist cart changes to local storage immediately
    CartStorage.saveCart();
  }

  void _addToCart(Product product) {
    setState(() {
      product.inCart = true;
      if (product.quantity < 1) {
        product.quantity = 1;
      }
      _syncToCart(product);
    });
    _showSnackBar('${product.title} added to the cart', Colors.green);
  }

  void _incrementCartQuantity(Product product) {
    setState(() {
      product.quantity++;
      _syncToCart(product);
    });
  }

  void _decrementCartQuantity(Product product) {
    bool justRemoved = false;
    setState(() {
      if (product.quantity > 1) {
        product.quantity--;
      } else {
        product.inCart = false;
        justRemoved = true;
      }
      _syncToCart(product);
    });

    if (justRemoved) {
      _showSnackBar('${product.title} removed from the cart', Colors.redAccent);
    }
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

  /// Open product detail screen and sync favorites/cart state when returning
  Future<void> _navigateToProductDetail(Product product) async {
    final selectedProduct = allProductDetails.firstWhere(
          (p) => p.name.trim().toLowerCase() == product.title.trim().toLowerCase(),
      orElse: () => allProductDetails.first,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: selectedProduct),
      ),
    );

    _syncProductsWithFavorites();
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const ProfileScreen();
      case 2:
        return FavoritesScreen(
          onFavoriteChanged: () {
            _syncProductsWithFavorites();
            FavoriteStorage.saveFavorites();
          },
        );
      case 3:
        return const ShoppingCartScreen();
      case 0:
      default:
        return SafeArea(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search keywords..',
                    hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 14),
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
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategorySelectionScreen(),
                          ),
                        );
                        _syncProductsWithFavorites();
                      },
                      icon:
                      const Icon(Icons.chevron_right, color: Colors.grey),
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
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return _ProductCard(
                      product: product,
                      onTap: () => _navigateToProductDetail(product),
                      onFavoriteToggle: () => _toggleFavorite(product.id),
                      onAddToCart: () => _addToCart(product),
                      onIncrement: () => _incrementCartQuantity(product),
                      onDecrement: () => _decrementCartQuantity(product),
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (_selectedIndex == 0) {
              _syncProductsWithFavorites();
            }
          });
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
// PRODUCT CARD WIDGET
// ======================================================
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final double numericPrice =
        double.tryParse(product.price.replaceAll('\$', '')) ?? 0.0;

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
                          child: product.isNetwork
                              ? Image.network(product.imagePath,
                              fit: BoxFit.contain)
                              : Image.asset(product.imagePath,
                              fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${numericPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF7AC142),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        product.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        product.subtitle,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFF2F4F7)),
              SizedBox(
                height: 38,
                child: product.inCart
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
                      '${product.quantity}',
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
          if (product.badge != null)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.badge == 'NEW'
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.badge!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: product.badge == 'NEW'
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
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: product.isFavorite ? Colors.red : Colors.grey[400],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}