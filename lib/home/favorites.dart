import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import 'product_detail_screen.dart';
import '../providers/products_provider.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback onFavoriteChanged;

  const FavoritesScreen({
    super.key,
    required this.onFavoriteChanged,
  });

  @override
  State<FavoritesScreen> createState() =>
      _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // ============================================================
  // LOCAL REMOVING STATE
  // ============================================================

  bool _isRemoving = false;

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  Future<void> _removeFromFavorites(
      ProductItem product,
      ) async {
    if (_isRemoving) return;

    _isRemoving = true;

    final String productName = product.name;

    // ----------------------------------------------------------
    // Remove from FavoritesProvider
    // ----------------------------------------------------------

    final FavoritesProvider favoritesProvider =
    context.read<FavoritesProvider>();

    await favoritesProvider.removeFavoriteById(
      product.id,
    );

    // ----------------------------------------------------------
    // Update ProductItem
    // ----------------------------------------------------------

    product.isFavorite = false;

    // ----------------------------------------------------------
    // Wait until the Dismissible/list rebuild is completed
    // ----------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Future.delayed(
        const Duration(milliseconds: 300),
            () {
          if (!mounted) return;

          _isRemoving = false;

          // ----------------------------------------------------
          // Show specific product SnackBar
          // ----------------------------------------------------

          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$productName removed from favorites',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // ----------------------------------------------------
          // Synchronize HomeScreen
          // ----------------------------------------------------

          widget.onFavoriteChanged();
        },
      );
    });
  }

  // ============================================================
  // OPEN PRODUCT DETAILS
  // ============================================================

  void _openProductDetails(
      ProductItem product,
      ) {
    try {
      final ProductDetail productDetail =
      allProductDetails.firstWhere(
            (detail) => detail.id == product.id,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: productDetail,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Favorite product not found: ${product.name}',
      );
    }
  }

  // ============================================================
  // EMPTY FAVORITES
  // ============================================================

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to your favorites',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAVORITE CARD
  // ============================================================

  Widget _buildFavoriteCard(
      ProductItem product,
      int index,
      ) {
    return Dismissible(
      key: ValueKey(
        'favorite_${product.id}',
      ),
      direction: DismissDirection.endToStart,

      // --------------------------------------------------------
      // SWIPE BACKGROUND
      // --------------------------------------------------------

      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),

      // --------------------------------------------------------
      // DISMISSED
      // --------------------------------------------------------

      onDismissed: (_) {
        _removeFromFavorites(product);
      },

      // --------------------------------------------------------
      // CARD
      // --------------------------------------------------------

      child: GestureDetector(
        onTap: () {
          _openProductDetails(product);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // ==================================================
              // PRODUCT IMAGE
              // ==================================================

              Container(
                width: 75,
                height: 75,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.imagePath.isNotEmpty
                    ? Image.asset(
                  product.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    );
                  },
                )
                    : const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // PRODUCT INFORMATION
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (product.weight.isNotEmpty)
                      Text(
                        product.weight,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 7),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // REMOVE FAVORITE BUTTON
              // ==================================================

              IconButton(
                onPressed: () {
                  _removeFromFavorites(product);
                },
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // removes the back arrow
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Consumer2<FavoritesProvider, ProductProvider>(
        builder: (
            context,
            favoritesProvider,
            productProvider,
            child,
            ) {
          // ----------------------------------------------------
          // GET FAVORITE PRODUCTS
          // ----------------------------------------------------

          final List<ProductItem> favoriteProducts =
          favoritesProvider.getFavoriteProducts(
            productProvider,
          );

          // ----------------------------------------------------
          // EMPTY FAVORITES
          // ----------------------------------------------------

          if (favoriteProducts.isEmpty) {
            return _buildEmptyFavorites();
          }

          // ----------------------------------------------------
          // FAVORITES LIST
          // ----------------------------------------------------

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 20,
            ),
            itemCount: favoriteProducts.length,
            itemBuilder: (
                context,
                index,
                ) {
              final ProductItem product =
              favoriteProducts[index];

              return _buildFavoriteCard(
                product,
                index,
              );
            },
          );
        },
      ),
    );
  }
}
