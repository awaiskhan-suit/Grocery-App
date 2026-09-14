import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_provider.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadPersistedData();
    });
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

  Future<void> _navigateToProductDetail(VegetableProduct product) async {
    final selectedProduct = allProductDetails.firstWhere(
          (p) => p.name.trim().toLowerCase() == product.name.trim().toLowerCase(),
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

    if (mounted) {
      context.read<ProductProvider>().loadPersistedData();
    }
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

          // Products Grid via Consumer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  final vegetableProducts = provider.vegetableProducts;

                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 12),
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

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            // Tag
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

                            // Favorite Button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: Icon(
                                  product.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: product.isFavorite
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  provider.toggleFavorite(product);
                                  _showSnackBar(
                                    product.isFavorite
                                        ? '${product.name} added to favorites'
                                        : '${product.name} removed from favorites',
                                    product.isFavorite
                                        ? Colors.green
                                        : Colors.redAccent,
                                  );
                                },
                              ),
                            ),

                            // Main Content with Image Provider Access
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),

                                  // Image Navigation
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

                                  // Price Display
                                  Text(
                                    "\$${product.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Name
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

                                  // Weight
                                  Text(
                                    product.weight,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Quantity / Add to Cart
                                  SizedBox(
                                    height: 36,
                                    child: product.inCart
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
                                            bool wasRemoved = provider
                                                .decrementCartQuantity(
                                                product);
                                            if (wasRemoved) {
                                              _showSnackBar(
                                                '${product.name} removed from the cart',
                                                Colors.redAccent,
                                              );
                                            }
                                          },
                                        ),
                                        Text(
                                          "${product.quantity}",
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
                                            provider.incrementCartQuantity(
                                                product);
                                          },
                                        ),
                                      ],
                                    )
                                        : InkWell(
                                      onTap: () {
                                        provider.addToCart(product);
                                        _showSnackBar(
                                          '${product.name} added to the cart',
                                          Colors.green,
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