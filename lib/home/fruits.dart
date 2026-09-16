import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/fruit_provider.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';
import '../providers/product_provider.dart';

class FruitsScreen extends StatefulWidget {
  const FruitsScreen({Key? key}) : super(key: key);

  @override
  State<FruitsScreen> createState() => _FruitsScreenState();
}

class _FruitsScreenState extends State<FruitsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ======================================================
  // SHOW SNACKBAR
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

  Future<void> _navigateToProductDetail(ProductItem fruit) async {
    ProductDetail? selectedProduct;

    try {
      selectedProduct = allProductDetails.firstWhere(
            (product) =>
        product.name.trim().toLowerCase() ==
            fruit.name.trim().toLowerCase(),
      );
    } catch (_) {
      selectedProduct = null;
    }

    if (selectedProduct == null) {
      _showSnackBar(
        '${fruit.name} details are not available',
        Colors.redAccent,
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: selectedProduct!,
        ),
      ),
    );
  }

  // ======================================================
  // TOGGLE FAVORITE
  // ======================================================

  Future<void> _toggleFavorite(
      ProductItem fruit,
      FavoritesProvider favoritesProvider,
      ) async {
    await favoritesProvider.toggleFavoriteById(fruit.id);

    if (!mounted) return;

    final bool isFavorite = favoritesProvider.isFavorite(fruit.id);

    _showSnackBar(
      isFavorite
          ? '${fruit.name} added to favorites'
          : '${fruit.name} removed from favorites',
      isFavorite ? Colors.green : Colors.redAccent,
    );
  }

  // ======================================================
  // ADD TO CART
  // ======================================================

  Future<void> _addToCart(ProductItem fruit) async {
    final cartProvider = context.read<CartProvider>();

    await cartProvider.addToCart(fruit);

    if (!mounted) return;

    _showSnackBar(
      '${fruit.name} added to the cart',
      Colors.green,
    );
  }

  // ======================================================
  // INCREMENT QUANTITY
  // ======================================================

  Future<void> _incrementQuantity(String productId) async {
    final cartProvider = context.read<CartProvider>();

    await cartProvider.incrementQuantity(productId);
  }

  // ======================================================
  // DECREMENT QUANTITY
  // ======================================================

  Future<void> _decrementQuantity(ProductItem fruit) async {
    final cartProvider = context.read<CartProvider>();

    final bool wasRemoved =
    await cartProvider.decrementQuantity(fruit.id);

    if (!mounted) return;

    if (wasRemoved) {
      _showSnackBar(
        '${fruit.name} removed from the cart',
        Colors.redAccent,
      );
    }
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // ====================================================
      // APP BAR
      // ====================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
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

      // ====================================================
      // BODY
      // ====================================================

      body: Column(
        children: [
          // ==================================================
          // SEARCH BAR
          // ==================================================

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search fruits...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ==================================================
          // FRUITS GRID
          // ==================================================

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Consumer3<FruitProvider, FavoritesProvider,
                  CartProvider>(
                builder: (
                    context,
                    fruitProvider,
                    favoritesProvider,
                    cartProvider,
                    child,
                    ) {
                  // ------------------------------------------------
                  // ALL FRUITS
                  // ------------------------------------------------

                  final allFruits = fruitProvider.fruitProducts;

                  // ------------------------------------------------
                  // SEARCH FILTER
                  // ------------------------------------------------

                  final fruitProducts = allFruits.where((fruit) {
                    if (_searchText.isEmpty) {
                      return true;
                    }

                    return fruit.name
                        .toLowerCase()
                        .contains(_searchText);
                  }).toList();

                  // ------------------------------------------------
                  // EMPTY SEARCH RESULT
                  // ------------------------------------------------

                  if (fruitProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No fruits found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  // ------------------------------------------------
                  // GRID
                  // ------------------------------------------------

                  return GridView.builder(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 20,
                    ),
                    itemCount: fruitProducts.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    itemBuilder: (context, index) {
                      final fruit = fruitProducts[index];

                      // --------------------------------------------
                      // FAVORITE STATUS
                      // --------------------------------------------

                      final bool isFavorite =
                      favoritesProvider.isFavorite(fruit.id);

                      // --------------------------------------------
                      // CART STATUS
                      // --------------------------------------------

                      final bool inCart =
                      cartProvider.isInCart(fruit.id);

                      // --------------------------------------------
                      // CART QUANTITY
                      // --------------------------------------------

                      final int quantity =
                      cartProvider.getQuantity(fruit.id);

                      // --------------------------------------------
                      // TOTAL PRICE
                      // --------------------------------------------

                      final double totalPrice =
                          fruit.price * quantity;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            // ======================================
                            // TAG
                            // ======================================

                            if (fruit.tag.isNotEmpty)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fruit.tag == 'NEW'
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                    borderRadius:
                                    const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight:
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    fruit.tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: fruit.tag == 'NEW'
                                          ? Colors.orange
                                          : Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),

                            // ======================================
                            // FAVORITE BUTTON
                            // ======================================

                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _toggleFavorite(
                                    fruit,
                                    favoritesProvider,
                                  );
                                },
                              ),
                            ),

                            // ======================================
                            // PRODUCT CONTENT
                            // ======================================

                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),

                                  // ==================================
                                  // PRODUCT IMAGE
                                  // ==================================

                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _navigateToProductDetail(
                                          fruit,
                                        );
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                          Colors.orange.shade50,
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            fruit.imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) {
                                              return const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // ==================================
                                  // TOTAL PRICE
                                  // ==================================

                                  Text(
                                    '\$${totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  // ==================================
                                  // PRODUCT NAME
                                  // ==================================

                                  Text(
                                    fruit.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 2),

                                  // ==================================
                                  // WEIGHT
                                  // ==================================

                                  Text(
                                    fruit.weight,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // ==================================
                                  // CART CONTROLS
                                  // ==================================

                                  SizedBox(
                                    height: 36,
                                    child: !inCart
                                        ? InkWell(
                                      onTap: () {
                                        _addToCart(fruit);
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Icon(
                                            Icons
                                                .shopping_bag_outlined,
                                            size: 14,
                                            color: Color(
                                              0xFF4CAF50,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Add to cart',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceEvenly,
                                      children: [
                                        // ==========================
                                        // DECREASE
                                        // ==========================

                                        IconButton(
                                          padding:
                                          EdgeInsets.zero,
                                          constraints:
                                          const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.remove,
                                            size: 18,
                                            color: Color(
                                              0xFF4CAF50,
                                            ),
                                          ),
                                          onPressed: () {
                                            _decrementQuantity(
                                              fruit,
                                            );
                                          },
                                        ),

                                        // ==========================
                                        // QUANTITY
                                        // ==========================

                                        Text(
                                          quantity.toString(),
                                          style:
                                          const TextStyle(
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                            fontSize: 14,
                                          ),
                                        ),

                                        // ==========================
                                        // INCREASE
                                        // ==========================

                                        IconButton(
                                          padding:
                                          EdgeInsets.zero,
                                          constraints:
                                          const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.add,
                                            size: 18,
                                            color: Color(
                                              0xFF4CAF50,
                                            ),
                                          ),
                                          onPressed: () {
                                            _incrementQuantity(
                                              fruit.id,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
