import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_provider.dart';

// ======================================================
// PRODUCT DETAIL MODEL
// ======================================================
class ProductDetail {
  final String id;
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
// ALL PRODUCTS LIST
// ======================================================
List<ProductDetail> allProductDetails = [
  // ====================================================
  // VEGETABLES
  // ====================================================
  ProductDetail(
    id: 'v1',
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
    id: 'v2',
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
    id: 'v3',
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
    id: 'v4',
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

  // ====================================================
  // FRUITS
  // ====================================================
  ProductDetail(
    id: 'f1',
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
    id: 'f2',
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
    id: 'f3',
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

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  // ======================================================
  // LOAD FAVORITE STATUS
  // ======================================================
  Future<void> _loadFavoriteStatus() async {
    final favoritesProvider = context.read<FavoritesProvider>();

    // Ensure favorites are loaded from SharedPreferences
    await favoritesProvider.loadPersistedFavorites();

    if (!mounted) return;

    setState(() {
      isFavorite = favoritesProvider.isFavorite(widget.product.id);
    });
  }

  // ======================================================
  // TOGGLE FAVORITE
  // ======================================================
  Future<void> _toggleFavorite() async {
    final favoritesProvider = context.read<FavoritesProvider>();

    await favoritesProvider.toggleFavoriteById(widget.product.id);

    if (!mounted) return;

    final bool newStatus = favoritesProvider.isFavorite(widget.product.id);

    setState(() {
      isFavorite = newStatus;
    });

    _showSnackBar(
      newStatus
          ? '${widget.product.name} added to favorites'
          : '${widget.product.name} removed from favorites',
      newStatus ? Colors.green : Colors.redAccent,
    );
  }

  // ======================================================
  // ADD TO CART (using CartProvider)
  // ======================================================
  Future<void> _addToCart() async {
    final cartProvider = context.read<CartProvider>();
    final product = widget.product;

    // Create a temporary ProductItem that CartProvider understands
    final ProductItem tempProduct = ProductItem(
      id: product.id,
      name: product.name,
      weight: product.weight,
      price: product.price,
      imagePath: product.image,
      tag: '',
      bgColor: Color(int.parse(product.bgColor)),
      description: product.description,
      category: '',
    );

    // If item is already in cart → increment the required number of times
    if (cartProvider.isInCart(product.id)) {
      for (int i = 0; i < quantity; i++) {
        await cartProvider.incrementQuantity(product.id);
      }
    } else {
      // First time adding
      await cartProvider.addToCart(tempProduct);

      // If user selected more than 1, increment the rest
      for (int i = 1; i < quantity; i++) {
        await cartProvider.incrementQuantity(product.id);
      }
    }

    if (!mounted) return;

    _showSnackBar(
      '${product.name} added to cart',
      Colors.green,
    );
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
  // BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final totalPrice = product.price * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // MAIN CONTENT
            // ==================================================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // CIRCULAR HEADER IMAGE
                    // ==========================================
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
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ======================================
                        // BACK BUTTON
                        // ======================================
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

                    // ==========================================
                    // PRODUCT DETAILS
                    // ==========================================
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ====================================
                          // PRICE + FAVORITE
                          // ====================================
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
                                onPressed: _toggleFavorite,
                              ),
                            ],
                          ),

                          // ====================================
                          // PRODUCT NAME
                          // ====================================
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ====================================
                          // WEIGHT
                          // ====================================
                          Text(
                            product.weight,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // ====================================
                          // RATING
                          // ====================================
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

                          // ====================================
                          // DESCRIPTION
                          // ====================================
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

            // ==================================================
            // BOTTOM ACTION CONTROLS
            // ==================================================
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  // ============================================
                  // QUANTITY SELECTOR
                  // ============================================
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
                                  setState(() {
                                    quantity--;
                                  });
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
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ============================================
                  // ADD TO CART BUTTON
                  // ============================================
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
                      onPressed: _addToCart,
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