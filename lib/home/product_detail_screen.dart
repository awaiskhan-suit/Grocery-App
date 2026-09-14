import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'shopping_cart.dart';

// ======================================================
// GLOBAL FAVORITES LIST
// ======================================================
List<Map<String, dynamic>> favoriteItems = [];

// ======================================================
// PRODUCT DETAIL MODEL
// ======================================================
class ProductDetail {
  final int id;
  final String name;
  final String weight;
  final double price;
  final String image;
  final String description;
  final double rating;
  final int reviews;
  final String bgColor;

  ProductDetail({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.image,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.bgColor,
  });
}

// ======================================================
// ALL PRODUCTS LIST (Vegetables + Fruits)
// ======================================================
List<ProductDetail> allProductDetails = [
  // ===== Vegetables =====
  ProductDetail(
    id: 1,
    name: 'Fresh Tomato',
    weight: '1 dozen',
    price: 8.00,
    image: 'assets/images/tomato.png',
    description:
    'Fresh organic tomatoes sourced directly from local farm growers. These vine-ripened tomatoes are packed with flavor, juicy texture, and natural nutrients, making them perfect for salads, sauces, and everyday cooking.',
    rating: 4.8,
    reviews: 124,
    bgColor: '0xFFFFEBEE',
  ),
  ProductDetail(
    id: 2,
    name: 'Onion',
    weight: '2.0 lbs',
    price: 7.00,
    image: 'assets/images/onion.png',
    description:
    'Fresh and high-quality onions with strong flavor. Perfect for cooking, salads, and daily kitchen use.',
    rating: 4.6,
    reviews: 89,
    bgColor: '0xFFFFF3E0',
  ),
  ProductDetail(
    id: 3,
    name: 'Potato',
    weight: '1.50 lbs',
    price: 9.90,
    image: 'assets/images/potato.png',
    description:
    'Farm-fresh potatoes that are perfect for frying, boiling, and baking. High in quality and taste.',
    rating: 4.7,
    reviews: 112,
    bgColor: '0xFFFFF8E1',
  ),
  ProductDetail(
    id: 4,
    name: 'Carrot',
    weight: '5.0 lbs',
    price: 7.05,
    image: 'assets/images/carrot.png',
    description:
    'Crunchy and sweet fresh carrots packed with vitamins. Great for salads, juices, and cooking.',
    rating: 4.5,
    reviews: 76,
    bgColor: '0xFFFFF3E0',
  ),

  // ===== Fruits =====
  ProductDetail(
    id: 5,
    name: 'Fresh Peach',
    weight: 'dozen',
    price: 8.00,
    image: 'assets/images/peach.jpg',
    description:
    'Sweet and juicy fresh peaches. Perfect for desserts, smoothies, and healthy snacking.',
    rating: 4.9,
    reviews: 143,
    bgColor: '0xFFFFEBEE',
  ),
  ProductDetail(
    id: 6,
    name: 'Avocado',
    weight: '2.0 lbs',
    price: 7.00,
    image: 'assets/images/Avocado.jpg',
    description:
    'Creamy and nutritious avocados. Rich in healthy fats and perfect for salads, toast, and smoothies.',
    rating: 4.8,
    reviews: 167,
    bgColor: '0xFFE8F5E9',
  ),
  ProductDetail(
    id: 7,
    name: 'Pineapple',
    weight: '1.50 lbs',
    price: 9.90,
    image: 'assets/images/pinaple.jpg',
    description:
    'Tropical sweet pineapple full of vitamins. Great for juices, desserts, and fresh eating.',
    rating: 4.7,
    reviews: 98,
    bgColor: '0xFFFFFDE7',
  ),
];

// ======================================================
// PRODUCT DETAIL SCREEN
// ======================================================
class ProductDetailScreen extends StatefulWidget {
  final ProductDetail product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const String _favoritesKey = 'saved_favorites';
  static const String _cartKey = 'saved_cart_items';

  int quantity = 1;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = _checkIsFavorite(widget.product.id);
    _loadPersistedData();
  }

  // Safe check for favorite ID comparison (String vs int)
  bool _checkIsFavorite(int productId) {
    return favoriteItems.any((item) => item['id'].toString() == productId.toString());
  }

  // Load persistent state from SharedPreferences on screen startup
  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Favorites
    final List<String> savedFavsJson = prefs.getStringList(_favoritesKey) ?? [];
    favoriteItems.clear();
    for (String itemString in savedFavsJson) {
      try {
        final Map<String, dynamic> itemMap = jsonDecode(itemString);
        favoriteItems.add(itemMap);
      } catch (e) {}
    }

    // 2. Load Cart Items
    final List<String> savedCartJson = prefs.getStringList(_cartKey) ?? [];
    cartItems.clear();
    for (String itemString in savedCartJson) {
      try {
        final Map<String, dynamic> itemMap = jsonDecode(itemString);
        cartItems.add(itemMap);
      } catch (e) {}
    }

    // 3. Sync local state
    if (mounted) {
      setState(() {
        isFavorite = _checkIsFavorite(widget.product.id);
      });
    }
  }

  // Save favorites list to SharedPreferences
  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsJson = favoriteItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap['id'] = int.tryParse(item['id'].toString()) ?? item['id'];
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();

    await prefs.setStringList(_favoritesKey, favsJson);
  }

  // Save cart list to SharedPreferences
  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cartJson = cartItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap['id'] = item['id'].toString();
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();

    await prefs.setStringList(_cartKey, cartJson);
  }

  // Toggle favorite and sync to global list + storage
  void _toggleFavorite(ProductDetail product) {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      favoriteItems.add({
        'id': product.id,
        'title': product.name,
        'unit': product.weight,
        'price': '\$${product.price.toStringAsFixed(2)}',
        'imagePath': product.image,
      });
      _showSnackBar('${product.name} added to favorites', Colors.green);
    } else {
      favoriteItems.removeWhere(
              (item) => item['id'].toString() == product.id.toString());
      _showSnackBar('${product.name} removed from favorites', Colors.redAccent);
    }

    // Persist favorites
    _saveFavoritesToPrefs();

    // Sync state with home screen list if available
    try {
      final mainProduct = products.firstWhere(
            (p) => p.title.toLowerCase().contains(product.name.toLowerCase()),
      );
      mainProduct.isFavorite = isFavorite;
    } catch (e) {}
  }

  // Add product to global Cart + storage
  void _addToCart(ProductDetail product) {
    final existingIndex = cartItems.indexWhere(
          (item) => item['id'].toString() == product.id.toString(),
    );

    final cartData = {
      'id': product.id.toString(),
      'title': product.name,
      'unitPrice': product.price,
      'price': '\$${product.price.toStringAsFixed(2)} x $quantity',
      'unit': product.weight,
      'quantity': quantity,
      'imagePath': product.image,
    };

    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity'] += quantity;
      cartItems[existingIndex]['price'] =
      '\$${product.price.toStringAsFixed(2)} x ${cartItems[existingIndex]['quantity']}';
    } else {
      cartItems.add(cartData);
    }

    // Persist cart items
    _saveCartToPrefs();

    _showSnackBar('${product.name} added to cart', Colors.green);
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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final totalPrice = product.price * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= Circular Header Image =================
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(int.parse(product.bgColor)),
                              ),
                              child: Center(
                                child: ClipOval(
                                  child: Image.asset(
                                    product.image,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 18,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ================= Product Details =================
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\$${totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () => _toggleFavorite(product),
                              ),
                            ],
                          ),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.weight,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Rating
                          Row(
                            children: [
                              Text(
                                "${product.rating} ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                      (index) => Icon(
                                    Icons.star,
                                    size: 16,
                                    color: index < product.rating.floor()
                                        ? Colors.amber
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "(${product.reviews} reviews)",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            product.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= Bottom Action Controls =================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  // Quantity Selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quantity",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.remove,
                                color: Color(0xFF4CAF50),
                              ),
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() => quantity--);
                                }
                              },
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.add,
                                color: Color(0xFF4CAF50),
                              ),
                              onPressed: () {
                                setState(() => quantity++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _addToCart(product),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                "Add to cart",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
