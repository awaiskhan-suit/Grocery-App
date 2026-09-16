import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartItems;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ==================================================
              // CART ITEMS LIST
              // ==================================================
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final String id = item['id']?.toString() ?? '';
                    final String title = item['title']?.toString() ?? 'Item';
                    final String unit = item['unit']?.toString() ?? '';
                    final String imagePath =
                        item['imagePath']?.toString() ?? '';
                    final double unitPrice =
                        (item['unitPrice'] as num?)?.toDouble() ?? 0.0;
                    final int quantity =
                        (item['quantity'] as num?)?.toInt() ?? 1;
                    final double itemTotalPrice = unitPrice * quantity;

                    return Dismissible(
                      key: Key(id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        cartProvider.removeFromCart(id);

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$title removed from cart',
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
                      },
                      background: Container(
                        color: const Color(0xFFEE5253),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24.0),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product Image
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFFE8F5E9),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: imagePath.isNotEmpty
                                      ? Image.asset(
                                    imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  )
                                      : const Icon(
                                    Icons.image_not_supported,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${unitPrice.toStringAsFixed(2)} x $quantity = \$${itemTotalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      unit,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      cartProvider.incrementQuantity(id);
                                    },
                                    child: const Icon(
                                      Icons.add,
                                      color: Color(0xFF7AC142),
                                      size: 18,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final bool removed = await cartProvider
                                          .decrementQuantity(id);

                                      if (removed && context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '$title removed from cart',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Colors.redAccent,
                                            duration:
                                            const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Icon(
                                      Icons.remove,
                                      color: Color(0xFF7AC142),
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ==================================================
              // BOTTOM SUMMARY
              // ==================================================
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        Text(
                          '\$${cartProvider.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shipping charges',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        Text(
                          '\$${CartProvider.shippingCharge.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(height: 1, color: Color(0xFFF2F4F7)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: cartItems.isEmpty
                            ? null
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Proceeding to Checkout!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}