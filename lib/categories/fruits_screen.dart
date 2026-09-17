import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/product_card.dart';
import '../home/product_detail_screen.dart'; // adjust path if needed

class FruitsScreen extends StatelessWidget {
  const FruitsScreen({super.key});

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
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

  void _openProductDetail(BuildContext context, ProductItem product) {
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
        context,
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

  Future<void> _toggleFavorite(BuildContext context, ProductItem product) async {
    final favoritesProvider = context.read<FavoritesProvider>();
    await favoritesProvider.toggleFavoriteById(product.id);

    final bool isFavorite = favoritesProvider.isFavorite(product.id);

    _showSnackBar(
      context,
      isFavorite
          ? '${product.name} added to favorites'
          : '${product.name} removed from favorites',
      isFavorite ? Colors.green : Colors.redAccent,
    );
  }

  Future<void> _addToCart(BuildContext context, ProductItem product) async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.addToCart(product);
    _showSnackBar(context, '${product.name} added to cart', Colors.green);
  }

  Future<void> _incrementQuantity(BuildContext context, String productId) async {
    await context.read<CartProvider>().incrementQuantity(productId);
  }

  Future<void> _decrementQuantity(BuildContext context, ProductItem product) async {
    final bool removed =
    await context.read<CartProvider>().decrementQuantity(product.id);

    if (removed) {
      _showSnackBar(context, '${product.name} removed from cart', Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruits'),
        centerTitle: true,
      ),
      body: Consumer2<ProductProvider, CartProvider>(
        builder: (context, productProvider, cartProvider, child) {
          final fruits = productProvider.getProductsByCategoryId('c2');

          if (fruits.isEmpty) {
            return const Center(child: Text('No fruits available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: fruits.length,
            itemBuilder: (context, index) {
              final product = fruits[index];
              final bool isFavorite =
              context.watch<FavoritesProvider>().isFavorite(product.id);
              final bool inCart = cartProvider.isInCart(product.id);
              final int quantity = cartProvider.getQuantity(product.id);

              return ProductCard(
                product: product,
                isFavorite: isFavorite,
                inCart: inCart,
                quantity: quantity,
                onTap: () => _openProductDetail(context, product),
                onFavoriteToggle: () => _toggleFavorite(context, product),
                onAddToCart: () => _addToCart(context, product),
                onIncrement: () => _incrementQuantity(context, product.id),
                onDecrement: () => _decrementQuantity(context, product),
              );
            },
          );
        },
      ),
    );
  }
}