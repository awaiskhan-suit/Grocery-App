import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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

  // ============================================================
  // SNACKBAR
  // ============================================================

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

  // ============================================================
  // NAVIGATE TO PRODUCT DETAILS
  // ============================================================

  Future<void> _navigateToProductDetail(ProductItem product) async {
    ProductDetail? selectedProduct;

    try {
      selectedProduct = allProductDetails.firstWhere(
            (p) =>
        p.name.trim().toLowerCase() ==
            product.name.trim().toLowerCase(),
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

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: selectedProduct!,
        ),
      ),
    );
  }

  // ============================================================
  // TOGGLE FAVORITE
  // ============================================================

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

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> _addToCart(ProductItem product) async {
    final cartProvider = context.read<CartProvider>();

    await cartProvider.addToCart(product);

    if (!mounted) return;

    _showSnackBar(
      '${product.name} added to the cart',
      Colors.green,
    );
  }

  // ============================================================
  // INCREASE QUANTITY
  // ============================================================

  Future<void> _incrementQuantity(String productId) async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.incrementQuantity(productId);
  }

  // ============================================================
  // DECREASE QUANTITY
  // ============================================================

  Future<void> _decrementQuantity(ProductItem product) async {
    final cartProvider = context.read<CartProvider>();

    final bool wasRemoved =
    await cartProvider.decrementQuantity(product.id);

    if (!mounted) return;

    if (wasRemoved) {
      _showSnackBar(
        '${product.name} removed from the cart',
        Colors.redAccent,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // ========================================================
      // APP BAR
      // ========================================================
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        children: [
          // ======================================================
          // SEARCH BAR
          // ======================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vegetables...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ======================================================
          // PRODUCTS GRID
          // ======================================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer3<ProductProvider, FavoritesProvider,
                  CartProvider>(
                builder: (
                    context,
                    productProvider,
                    favoritesProvider,
                    cartProvider,
                    child,
                    ) {
                  // ------------------------------------------------
                  // GET VEGETABLES
                  // ------------------------------------------------
                  final allVegetables = productProvider.vegetableProducts;

                  // ------------------------------------------------
                  // SEARCH FILTER
                  // ------------------------------------------------
                  final vegetableProducts = allVegetables.where((product) {
                    if (_searchText.isEmpty) return true;
                    return product.name.toLowerCase().contains(_searchText);
                  }).toList();

                  // ------------------------------------------------
                  // EMPTY RESULT
                  // ------------------------------------------------
                  if (vegetableProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No vegetables found',
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
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    itemCount: vegetableProducts.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    itemBuilder: (context, index) {
                      final product = vegetableProducts[index];

                      final bool isFavorite =
                      favoritesProvider.isFavorite(product.id);
                      final bool isInCart =
                      cartProvider.isInCart(product.id);
                      final int quantity =
                      cartProvider.getQuantity(product.id);

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
                            if (product.tag.isNotEmpty)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.tag == 'NEW'
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    product.tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: product.tag == 'NEW'
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
                                  color: isFavorite ? Colors.red : Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () => _toggleFavorite(product),
                              ),
                            ),

                            // ======================================
                            // MAIN CONTENT
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
                                      onTap: () =>
                                          _navigateToProductDetail(product),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.orange.shade50,
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            product.imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) {
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
                                  // PRICE
                                  // ==================================
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  // ==================================
                                  // NAME
                                  // ==================================
                                  Text(
                                    product.name,
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
                                    product.weight,
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
                                    child: isInCart
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
                                              _decrementQuantity(product),
                                        ),
                                        Text(
                                          '$quantity',
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
                                              _incrementQuantity(
                                                  product.id),
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

