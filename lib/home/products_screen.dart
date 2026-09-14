import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites.dart'; // Access to global favoriteItems list
import 'home_screen.dart';
import 'product_detail_screen.dart';
import 'shopping_cart.dart'; // Access to global cartItems list and CartStorage

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const String _favoritesKey = 'saved_favorites';

  final List<Map<String, dynamic>> vegetableProducts = [
    {
      'id': 'v1',
      'name': 'Tomato',
      'weight': 'dozen',
      'price': 8.00,
      'image': 'assets/images/tomato.png',
      'tag': 'NEW',
      'isFavorite': false,
      'inCart': false,
      'quantity': 1,
      'bgColor': const Color(0xFFFFEBEE),
    },
    {
      'id': 'v2',
      'name': 'Onion',
      'weight': '2.0 lbs',
      'price': 7.00,
      'image': 'assets/images/onion.png',
      'tag': '',
      'isFavorite': false,
      'inCart': false,
      'quantity': 1,
      'bgColor': const Color(0xFFE8F5E9),
    },
    {
      'id': 'v3',
      'name': 'Potato',
      'weight': '1.50 lbs',
      'price': 9.90,
      'image': 'assets/images/potato.png',
      'tag': '',
      'isFavorite': false,
      'inCart': false,
      'quantity': 1,
      'bgColor': const Color(0xFFFFFDE7),
    },
    {
      'id': 'v4',
      'name': 'Carrot',
      'weight': '5.0 lbs',
      'price': 7.05,
      'image': 'assets/images/carrot.png',
      'tag': '-16%',
      'isFavorite': false,
      'inCart': false,
      'quantity': 1,
      'bgColor': const Color(0xFFFFF3E0),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
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
      } catch (e) {
        debugPrint('Failed to decode favorite item: $e');
      }
    }

    // 2. Load Cart Items via CartStorage
    await CartStorage.loadCart();

    // 3. Align local product UI states with restored lists using exact matches
    setState(() {
      for (var product in vegetableProducts) {
        // Sync favorite state via ID or exact name match
        product['isFavorite'] = favoriteItems.any(
              (item) =>
          item['id']?.toString() == product['id'].toString() ||
              (item['title'] != null &&
                  item['title'].toString().toLowerCase() ==
                      product['name'].toString().toLowerCase()),
        );

        // Sync cart state
        final cartIndex = cartItems.indexWhere(
              (item) =>
          item['id']?.toString() == product['id'].toString() ||
              (item['title'] != null &&
                  item['title'].toString().toLowerCase() ==
                      product['name'].toString().toLowerCase()),
        );

        if (cartIndex >= 0) {
          product['inCart'] = true;
          product['quantity'] = cartItems[cartIndex]['quantity'] ?? 1;
        } else {
          product['inCart'] = false;
          product['quantity'] = 1;
        }
      }
    });
  }

  // Save current favorite items to SharedPreferences
  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsJson = favoriteItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();

    await prefs.setStringList(_favoritesKey, favsJson);
  }

  void _toggleFavorite(Map<String, dynamic> product) {
    setState(() {
      product['isFavorite'] = !product['isFavorite'];

      if (product['isFavorite']) {
        final exists = favoriteItems.any(
              (item) =>
          item['id']?.toString() == product['id'].toString() ||
              (item['title'] != null &&
                  item['title'].toString().toLowerCase() ==
                      product['name'].toString().toLowerCase()),
        );
        if (!exists) {
          favoriteItems.add({
            'id': product['id'],
            'title': product['name'],
            'unit': product['weight'],
            'price': '\$${product['price'].toStringAsFixed(2)}',
            'imagePath': product['image'],
          });
        }
        _showFavoriteSnackBar('${product['name']} added to favorites', Colors.green);
      } else {
        favoriteItems.removeWhere(
              (item) =>
          item['id']?.toString() == product['id'].toString() ||
              (item['title'] != null &&
                  item['title'].toString().toLowerCase() ==
                      product['name'].toString().toLowerCase()),
        );
        _showFavoriteSnackBar('${product['name']} removed from favorites', Colors.redAccent);
      }
    });

    _saveFavoritesToPrefs();

    // Cross-sync with home screen products list using strict equality
    try {
      final mainProduct = products.firstWhere(
            (p) =>
        p.id == product['id'] ||
            p.title.trim().toLowerCase() ==
                product['name'].toString().trim().toLowerCase(),
      );
      mainProduct.isFavorite = product['isFavorite'];
    } catch (_) {}
  }

  void _syncToCart(Map<String, dynamic> product) {
    final existingIndex = cartItems.indexWhere(
          (item) =>
      item['id']?.toString() == product['id'].toString() ||
          (item['title'] != null &&
              item['title'].toString().toLowerCase() ==
                  product['name'].toString().toLowerCase()),
    );

    final double numericPrice = (product['price'] is num)
        ? (product['price'] as num).toDouble()
        : double.tryParse(product['price'].toString().replaceAll('\$', '')) ?? 0.0;

    if (product['inCart']) {
      final cartData = {
        'id': product['id'],
        'title': product['name'],
        'unitPrice': numericPrice,
        'price': '\$${numericPrice.toStringAsFixed(2)} x ${product['quantity']}',
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

    // Persist cart changes to local storage immediately
    CartStorage.saveCart();

    // Cross-sync with home screen products list
    try {
      final mainProduct = products.firstWhere(
            (p) =>
        p.id == product['id'] ||
            p.title.trim().toLowerCase() ==
                product['name'].toString().trim().toLowerCase(),
      );
      mainProduct.inCart = product['inCart'];
      mainProduct.quantity = product['quantity'];
    } catch (_) {}
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      product['inCart'] = true;
      if (product['quantity'] < 1) {
        product['quantity'] = 1;
      }
      _syncToCart(product);
    });
    _showAddToCartSnackBar(product['name']);
  }

  void _incrementCartQuantity(Map<String, dynamic> product) {
    setState(() {
      product['quantity']++;
      _syncToCart(product);
    });
  }

  void _decrementCartQuantity(Map<String, dynamic> product) {
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
      _showRemoveFromCartSnackBar(product['name']);
    }
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

  Future<void> _navigateToProductDetail(Map<String, dynamic> product) async {
    final selectedProduct = allProductDetails.firstWhere(
          (p) =>
      p.name.trim().toLowerCase() ==
          product['name'].toString().trim().toLowerCase(),
      orElse: () => allProductDetails.first,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: selectedProduct,
        ),
      ),
    );

    // Refresh state upon returning from detail view
    _loadPersistedData();
  }

  @override
  Widget build(BuildContext context) {
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
          'Vegetables',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                hintText: 'Search vegetables...',
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

          // Products Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 12),
                itemCount: vegetableProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.70,
                ),
                itemBuilder: (context, index) {
                  final product = vegetableProducts[index];
                  final double basePrice = (product['price'] is num)
                      ? (product['price'] as num).toDouble()
                      : 0.0;

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
                            onPressed: () => _toggleFavorite(product),
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
                                  onTap: () => _navigateToProductDetail(product),
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
                                "\$${basePrice.toStringAsFixed(2)}",
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

                              // Quantity / Add to cart Controls
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
                                      onPressed: () =>
                                          _decrementCartQuantity(product),
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
                                      onPressed: () =>
                                          _incrementCartQuantity(product),
                                    ),
                                  ],
                                )
                                    : InkWell(
                                  onTap: () => _addToCart(product),
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