import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites.dart'; // Global favoriteItems list
import 'home_screen.dart';
import 'product_detail_screen.dart';
import 'shopping_cart.dart'; // Global cartItems list

class FruitsScreen extends StatefulWidget {
  const FruitsScreen({Key? key}) : super(key: key);

  @override
  State<FruitsScreen> createState() => _FruitsScreenState();
}

class _FruitsScreenState extends State<FruitsScreen> {
  static const String _favoritesKey = 'saved_favorites';
  static const String _cartKey = 'saved_cart_items';

  final List<Map<String, dynamic>> fruits = [
    {
      'id': 'h0',
      'name': 'Fresh Peach',
      'weight': 'dozen',
      'price': 8.00,
      'image': 'assets/images/peach.jpg',
      'tag': 'NEW',
      'isFavorite': false,
      'inCart': false,
      'quantity': 1,
      'bgColor': const Color(0xFFFFF3E0),
      'description':
      'Fresh and juicy organic peaches picked directly from the farm. Rich in vitamins and natural sweetness.',
    },
    {
      'id': 'h1',
      'name': 'Avocado',
      'weight': '2.0 lbs',
      'price': 7.00,
      'image': 'assets/images/Avocado.jpg',
      'tag': 'NEW',
      'isFavorite': false,
      'inCart': false,
      'quantity': 1,
      'bgColor': const Color(0xFFE8F5E9),
      'description':
      'Creamy, fresh Hass avocados packed with healthy fats and essential nutrients. Perfect for salads and toast.',
    },
    {
      'id': 'h2',
      'name': 'Pineapple',
      'weight': '1.50 lbs',
      'price': 9.90,
      'image': 'assets/images/pinaple.jpg',
      'tag': '',
      'isFavorite': false,
      'inCart': false,
      'quantity': 1,
      'bgColor': const Color(0xFFFFFDE7),
      'description':
      'Sweet and tropical ripe pineapples. High in vitamin C and perfect for refreshing juices and snacks.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> savedFavsJson = prefs.getStringList(_favoritesKey) ?? [];
    if (favoriteItems.isEmpty && savedFavsJson.isNotEmpty) {
      for (String itemString in savedFavsJson) {
        try {
          final Map<String, dynamic> itemMap = jsonDecode(itemString);
          if (itemMap['id'] != null) {
            favoriteItems.add(itemMap);
          }
        } catch (_) {}
      }
    }

    final List<String> savedCartJson = prefs.getStringList(_cartKey) ?? [];
    if (cartItems.isEmpty && savedCartJson.isNotEmpty) {
      for (String itemString in savedCartJson) {
        try {
          final Map<String, dynamic> itemMap = jsonDecode(itemString);
          if (itemMap['id'] != null) {
            cartItems.add(itemMap);
          }
        } catch (_) {}
      }
    }

    _syncLocalState();
  }

  void _syncLocalState() {
    final Set<String> favIds = favoriteItems
        .where((item) => item['id'] != null)
        .map((item) => item['id'].toString())
        .toSet();

    final Set<String> cartIds = cartItems
        .where((item) => item['id'] != null)
        .map((item) => item['id'].toString())
        .toSet();

    setState(() {
      for (var fruit in fruits) {
        final String fruitId = fruit['id'].toString();

        fruit['isFavorite'] = favIds.contains(fruitId);

        fruit['inCart'] = cartIds.contains(fruitId);
        if (fruit['inCart']) {
          final cartItem = cartItems.firstWhere(
                (item) => item['id'].toString() == fruitId,
          );
          fruit['quantity'] = cartItem['quantity'] ?? 1;
        } else {
          fruit['quantity'] = 1;
        }
      }
    });
  }

  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsJson = favoriteItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();

    await prefs.setStringList(_favoritesKey, favsJson);
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cartJson = cartItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();

    await prefs.setStringList(_cartKey, cartJson);
  }

  void _toggleFavorite(Map<String, dynamic> fruit) {
    setState(() {
      fruit['isFavorite'] = !fruit['isFavorite'];
      final String fruitId = fruit['id'].toString();

      if (fruit['isFavorite']) {
        final exists = favoriteItems.any(
              (item) => item['id']?.toString() == fruitId,
        );

        if (!exists) {
          favoriteItems.add({
            'id': fruit['id'],
            'title': fruit['name'],
            'unit': fruit['weight'],
            'price': '\$${fruit['price'].toStringAsFixed(2)}',
            'imagePath': fruit['image'],
          });
        }
        _showFavoriteSnackBar(
          '${fruit['name']} added to favorites',
          Colors.green,
        );
      } else {
        favoriteItems.removeWhere(
              (item) => item['id']?.toString() == fruitId,
        );
        _showFavoriteSnackBar(
          '${fruit['name']} removed from favorites',
          Colors.redAccent,
        );
      }
    });

    _saveFavoritesToPrefs();

    try {
      final mainProduct = products.firstWhere(
            (p) => p.id.toString() == fruit['id'].toString(),
      );
      mainProduct.isFavorite = fruit['isFavorite'];
    } catch (_) {}
  }

  void _showFavoriteSnackBar(String message, Color bgColor) {
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

  void _syncToCart(Map<String, dynamic> product) {
    final String productId = product['id'].toString();
    final existingIndex = cartItems.indexWhere(
          (item) => item['id']?.toString() == productId,
    );

    if (product['inCart']) {
      final cartData = {
        'id': product['id'],
        'title': product['name'],
        'unitPrice': product['price'],
        'price':
        '\$${product['price'].toStringAsFixed(2)} x ${product['quantity']}',
        'unit': product['weight'],
        'quantity': product['quantity'],
        'imagePath': product['image'],
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

    _saveCartToPrefs();
  }

  void _showAddToCartSnackBar(String productName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$productName added to the cart',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showRemoveFromCartSnackBar(String productName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$productName removed from the cart',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.redAccent,
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
    _syncLocalState();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Fruits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search fruits...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Fruits Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: fruits.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final product = fruits[index];

                  final double basePrice = product['price'];
                  final int quantity = product['quantity'];
                  final double totalPrice = basePrice * quantity;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Tag
                        if (product['tag'].toString().isNotEmpty)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: product['tag'] == 'NEW'
                                    ? Colors.orange.shade100
                                    : Colors.red.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                product['tag'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: product['tag'] == 'NEW'
                                      ? Colors.orange
                                      : Colors.redAccent,
                                ),
                              ),
                            ),
                          ),

                        // Favorite Icon
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: Icon(
                              product['isFavorite']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product['isFavorite']
                                  ? Colors.red
                                  : Colors.grey,
                              size: 18,
                            ),
                            onPressed: () {
                              _toggleFavorite(product);
                            },
                          ),
                        ),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),

                              // Image Navigation
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final selectedProduct =
                                    allProductDetails.firstWhere(
                                          (p) =>
                                      p.name.trim().toLowerCase() ==
                                          product['name']
                                              .toString()
                                              .trim()
                                              .toLowerCase(),
                                      orElse: () => allProductDetails.first,
                                    );

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailScreen(
                                              product: selectedProduct,
                                            ),
                                      ),
                                    );

                                    _loadPersistedData();
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.orange.shade50,
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        product['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                        const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Base Price Display
                              Text(
                                "\$${totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),

                              // Name
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),

                              // Weight
                              Text(
                                product['weight'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Quantity / Add to Cart Controls
                              SizedBox(
                                height: 36,
                                child: product['inCart']
                                    ? Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints:
                                      const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.remove,
                                        size: 18,
                                        color: Color(0xFF4CAF50),
                                      ),
                                      onPressed: () {
                                        bool justRemoved = false;
                                        setState(() {
                                          if (product['quantity'] > 1) {
                                            product['quantity']--;
                                          } else {
                                            product['inCart'] = false;
                                            justRemoved = true;
                                          }
                                          _syncToCart(product);
                                        });

                                        if (justRemoved) {
                                          _showRemoveFromCartSnackBar(
                                            product['name'],
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      "${product['quantity']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints:
                                      const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Color(0xFF4CAF50),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          product['quantity']++;
                                          _syncToCart(product);
                                        });
                                      },
                                    ),
                                  ],
                                )
                                    : InkWell(
                                  onTap: () {
                                    setState(() {
                                      product['inCart'] = true;
                                      _syncToCart(product);
                                    });
                                    _showAddToCartSnackBar(
                                      product['name'],
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 14,
                                        color: Color(0xFF4CAF50),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Add to cart",
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
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
