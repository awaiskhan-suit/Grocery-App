import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fruit_provider.dart';
import 'product_provider.dart' hide ProductProvider;
import 'product_detail_screen.dart';

class FruitsScreen extends StatefulWidget {
  const FruitsScreen({Key? key}) : super(key: key);

  @override
  State<FruitsScreen> createState() => _FruitsScreenState();
}

class _FruitsScreenState extends State<FruitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FruitProvider>().loadPersistedData();
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

  Future<void> _navigateToProductDetail(FruitProduct fruit) async {
    final selectedProduct = allProductDetails.firstWhere(
          (p) => p.name.trim().toLowerCase() == fruit.name.trim().toLowerCase(),
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
      context.read<FruitProvider>().loadPersistedData();
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
          'Fruits',
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

          // Fruits Grid via Consumer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Consumer<FruitProvider>(
                builder: (context, provider, child) {
                  final fruitProducts = provider.fruitProducts;

                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 12),
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
                      final double totalPrice = fruit.price * fruit.quantity;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            // Tag
                            if (fruit.tag.isNotEmpty)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fruit.tag == 'NEW'
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
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

                            // Favorite Icon Button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: Icon(
                                  fruit.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: fruit.isFavorite
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  provider.toggleFruitFavorite(fruit);
                                  _showSnackBar(
                                    fruit.isFavorite
                                        ? '${fruit.name} added to favorites'
                                        : '${fruit.name} removed from favorites',
                                    fruit.isFavorite
                                        ? Colors.green
                                        : Colors.redAccent,
                                  );
                                },
                              ),
                            ),

                            // Main Card Details
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),

                                  // Image Container with Detail Navigation
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          _navigateToProductDetail(fruit),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.orange.shade50,
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            fruit.imagePath,
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

                                  // Total Price Display
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

                                  // Weight
                                  Text(
                                    fruit.weight,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Cart Controls
                                  SizedBox(
                                    height: 36,
                                    child: fruit.inCart
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
                                                .decrementFruitCartQuantity(
                                                fruit);
                                            if (wasRemoved) {
                                              _showSnackBar(
                                                '${fruit.name} removed from the cart',
                                                Colors.redAccent,
                                              );
                                            }
                                          },
                                        ),
                                        Text(
                                          "${fruit.quantity}",
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
                                            provider
                                                .incrementFruitCartQuantity(
                                                fruit);
                                          },
                                        ),
                                      ],
                                    )
                                        : InkWell(
                                      onTap: () {
                                        provider.addFruitToCart(fruit);
                                        _showSnackBar(
                                          '${fruit.name} added to the cart',
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