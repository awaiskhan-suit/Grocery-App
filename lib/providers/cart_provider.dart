import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'product_provider.dart';

class CartProvider extends ChangeNotifier {
  static const String _prefsKey = 'saved_cart_items';

  final List<Map<String, dynamic>> _cartItems = [];

  CartProvider() {
    loadCart();
  }

  // ======================================================
  // GETTERS
  // ======================================================

  List<Map<String, dynamic>> get cartItems =>
      List.unmodifiable(_cartItems);

  int get cartCount {
    int count = 0;

    for (final item in _cartItems) {
      count += (item['quantity'] as num?)?.toInt() ?? 1;
    }

    return count;
  }

  int get uniqueItemCount => _cartItems.length;

  double get subtotal {
    double total = 0.0;

    for (final item in _cartItems) {
      final double price =
          (item['unitPrice'] as num?)?.toDouble() ?? 0.0;

      final int quantity =
          (item['quantity'] as num?)?.toInt() ?? 1;

      total += price * quantity;
    }

    return total;
  }

  static const double shippingCharge = 1.60;

  double get totalAmount {
    return subtotal > 0 ? subtotal + shippingCharge : 0.0;
  }

  bool get isEmpty => _cartItems.isEmpty;

  bool get isNotEmpty => _cartItems.isNotEmpty;

  // ======================================================
  // LOAD CART
  // ======================================================

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> savedCart =
          prefs.getStringList(_prefsKey) ?? [];

      _cartItems.clear();

      for (final itemString in savedCart) {
        try {
          final Map<String, dynamic> item =
          jsonDecode(itemString);

          if (item['id'] != null) {
            _cartItems.add(item);
          }
        } catch (e) {
          debugPrint(
            'Failed to decode cart item: $e',
          );
        }
      }

      notifyListeners();

      debugPrint(
        'Cart loaded successfully: ${_cartItems.length} items',
      );
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // ======================================================
  // SAVE CART
  // ======================================================

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> cartJsonList =
      _cartItems.map((item) {
        final Map<String, dynamic> data =
        Map<String, dynamic>.from(item);

        // Color objects cannot be encoded by jsonEncode.
        data.remove('bgColor');

        return jsonEncode(data);
      }).toList();

      await prefs.setStringList(
        _prefsKey,
        cartJsonList,
      );

      debugPrint(
        'Cart saved successfully: ${_cartItems.length} items',
      );
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // ======================================================
  // FIND CART ITEM
  // ======================================================

  int _findItemIndex(String productId) {
    return _cartItems.indexWhere(
          (item) => item['id']?.toString() == productId,
    );
  }

  // ======================================================
  // CHECK IF PRODUCT IS IN CART
  // ======================================================

  bool isInCart(String productId) {
    return _findItemIndex(productId) >= 0;
  }

  // ======================================================
  // GET QUANTITY
  // ======================================================

  int getQuantity(String productId) {
    final index = _findItemIndex(productId);

    if (index < 0) {
      return 0;
    }

    return (_cartItems[index]['quantity'] as num?)?.toInt() ?? 1;
  }

  // ======================================================
  // ADD PRODUCT TO CART
  // ======================================================

  Future<void> addToCart(ProductItem product) async {
    final existingIndex = _findItemIndex(product.id);

    if (existingIndex >= 0) {
      final currentQuantity =
          (_cartItems[existingIndex]['quantity'] as num?)
              ?.toInt() ??
              1;

      _cartItems[existingIndex]['quantity'] =
          currentQuantity + 1;
    } else {
      _cartItems.add({
        'id': product.id,
        'title': product.name,
        'unitPrice': product.price,
        'price':
        '\$${product.price.toStringAsFixed(2)}',
        'unit': product.weight,
        'quantity': 1,
        'imagePath': product.imagePath,
      });
    }

    // Keep ProductItem synchronized for UI compatibility.
    product.inCart = true;
    product.quantity = getQuantity(product.id);

    notifyListeners();

    await _saveCart();

    debugPrint(
      'Added to cart: ${product.name}',
    );
  }

  // ======================================================
  // REMOVE PRODUCT FROM CART
  // ======================================================

  Future<void> removeFromCart(String productId) async {
    final index = _findItemIndex(productId);

    if (index < 0) {
      return;
    }

    _cartItems.removeAt(index);

    notifyListeners();

    await _saveCart();

    debugPrint(
      'Removed from cart: $productId',
    );
  }

  // ======================================================
  // INCREMENT QUANTITY
  // ======================================================

  Future<void> incrementQuantity(String productId) async {
    final index = _findItemIndex(productId);

    if (index < 0) {
      return;
    }

    final currentQuantity =
        (_cartItems[index]['quantity'] as num?)
            ?.toInt() ??
            1;

    _cartItems[index]['quantity'] =
        currentQuantity + 1;

    notifyListeners();

    await _saveCart();
  }

  // ======================================================
  // DECREMENT QUANTITY
  // ======================================================

  Future<bool> decrementQuantity(String productId) async {
    final index = _findItemIndex(productId);

    if (index < 0) {
      return false;
    }

    final currentQuantity =
        (_cartItems[index]['quantity'] as num?)
            ?.toInt() ??
            1;

    if (currentQuantity > 1) {
      _cartItems[index]['quantity'] =
          currentQuantity - 1;

      notifyListeners();

      await _saveCart();

      return false;
    }

    _cartItems.removeAt(index);

    notifyListeners();

    await _saveCart();

    return true;
  }

  // ======================================================
  // CLEAR CART
  // ======================================================

  Future<void> clearCart() async {
    _cartItems.clear();

    notifyListeners();

    await _saveCart();

    debugPrint('Cart cleared');
  }

  // ======================================================
  // SYNC PRODUCT OBJECTS
  // ======================================================

  void syncProducts(List<ProductItem> products) {
    for (final product in products) {
      final quantity = getQuantity(product.id);

      product.inCart = quantity > 0;
      product.quantity = quantity > 0 ? quantity : 1;
    }

    notifyListeners();
  }
}
