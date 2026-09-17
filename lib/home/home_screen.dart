import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../categories/fruits_screen.dart';
import '../categories/vegetables_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/category_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart'; // ← added

import 'category_dashboard.dart';
import 'product_detail_screen.dart';
import 'favorites.dart';
import 'shopping_cart.dart';
import 'package:grocery/home/profile.dart';

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

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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

  // ======================================================
  // SNACKBAR
  // ======================================================
  void _showSnackBar(String message, Color bgColor) {
    if (!mounted) return;

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

  // ======================================================
  // OPEN PRODUCT DETAIL
  // ======================================================
  void _openProductDetail(ProductItem product) {
    ProductDetail? selectedProduct;

    try {
      selectedProduct = allProductDetails.firstWhere(
            (p) => p.id == product.id,
      );
    } catch (_) {
      selectedProduct = null;
    }

    if (selectedProduct == null) {
      _showSnackBar(
        '${product.name} details are not available',
        Colors.redAccent,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: selectedProduct!),
      ),
    );
  }

  // ======================================================
  // TOGGLE FAVORITE
  // ======================================================
  Future<void> _toggleFavorite(ProductItem product) async {
    final favoritesProvider = context.read<FavoritesProvider>();

    await favoritesProvider.toggleFavoriteById(product.id);

    if (!mounted) return;

    final bool isFavorite = favoritesProvider.isFavorite(product.id);

    _showSnackBar(
      isFavorite
          ? '${product.name} added to favorites'
          : '${product.name} removed from favorites',
      isFavorite ? Colors.green : Colors.redAccent,
    );
  }

  // ======================================================
  // ADD TO CART
  // ======================================================
  Future<void> _addToCart(ProductItem product) async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.addToCart(product);

    if (!mounted) return;
    _showSnackBar('${product.name} added to cart', Colors.green);
  }

  // ======================================================
  // INCREMENT / DECREMENT
  // ======================================================
  Future<void> _incrementQuantity(String productId) async {
    await context.read<CartProvider>().incrementQuantity(productId);
  }

  Future<void> _decrementQuantity(ProductItem product) async {
    final bool removed =
    await context.read<CartProvider>().decrementQuantity(product.id);

    if (!mounted) return;

    if (removed) {
      _showSnackBar('${product.name} removed from cart', Colors.redAccent);
    }
  }

  // ======================================================
  // CATEGORY CHIP TAP (quick access row)
  // ======================================================
  void _onCategoryTap(CategoryItem category) {
    final productProvider = context.read<ProductProvider>();
    final products = productProvider.getProductsByCategoryId(category.id);

    if (products.isEmpty) {
      _showSnackBar('${category.title} coming soon!', Colors.orange);
      return;
    }

    // Directly open the correct product screen
    if (category.id == 'c1') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VegetablesScreen()),
      );
    } else if (category.id == 'c2') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FruitsScreen()),
      );
    } else {
      _showSnackBar('${category.title} coming soon!', Colors.orange);
    }
  }

  // ======================================================
  // BODY
  // ======================================================
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const ProfileScreen();
      case 2:
        return FavoritesScreen(
          onFavoriteChanged: () {
            setState(() {});
          },
        );
      case 3:
        return const ShoppingCartScreen();
      case 0:
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================== SEARCH BAR ======================
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

            // ====================== BANNER SLIDER ======================
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

            // ====================== CATEGORIES ======================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryScreenDashboard(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quick-access category row
            const SizedBox(height: 20),

            // ====================== FEATURED PRODUCTS ======================
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

            // All products from ProductProvider (family style)
            Consumer2<ProductProvider, CartProvider>(
              builder: (context, productProvider, cartProvider, _) {
                final allProducts = productProvider.allProducts;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = allProducts[index];
                    final bool isFavorite =
                    context.watch<FavoritesProvider>().isFavorite(product.id);
                    final bool inCart = cartProvider.isInCart(product.id);
                    final int quantity = cartProvider.getQuantity(product.id);

                    return ProductCard( // ← changed from _ProductCard
                      product: product,
                      isFavorite: isFavorite,
                      inCart: inCart,
                      quantity: quantity,
                      onTap: () => _openProductDetail(product),
                      onFavoriteToggle: () => _toggleFavorite(product),
                      onAddToCart: () => _addToCart(product),
                      onIncrement: () => _incrementQuantity(product.id),
                      onDecrement: () => _decrementQuantity(product),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
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
// PRODUCT CARD
// ======================================================
class _ProductCard extends StatelessWidget {
  final ProductItem product;
  final bool isFavorite;
  final bool inCart;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.inCart,
    required this.quantity,
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
                          child: Image.asset(
                            product.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF7AC142),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        product.weight,
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
          if (product.tag.isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.tag == 'NEW'
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: product.tag == 'NEW'
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