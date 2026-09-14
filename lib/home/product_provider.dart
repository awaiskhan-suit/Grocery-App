import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grocery/home/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites.dart';
import 'home_screen.dart';
import 'shopping_cart.dart';

class VegetableProduct {
  final String id;
  final String name;
  final String weight;
  final double price;
  final String imagePath;
  final String tag;
  final Color bgColor;
  bool isFavorite;
  bool inCart;
  int quantity;

  VegetableProduct({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.imagePath,
    required this.tag,
    required this.bgColor,
    this.isFavorite = false,
    this.inCart = false,
    this.quantity = 1,
  });
}

class ProductProvider with ChangeNotifier {
  static const String _favoritesKey = 'saved_favorites';

  final List<VegetableProduct> _vegetableProducts = [
    VegetableProduct(
      id: 'v1',
      name: 'Tomato',
      weight: 'dozen',
      price: 8.00,
      imagePath: 'assets/images/tomato.png',
      tag: 'NEW',
      bgColor: const Color(0xFFFFEBEE),
    ),
    VegetableProduct(
      id: 'v2',
      name: 'Onion',
      weight: '2.0 lbs',
      price: 7.00,
      imagePath: 'assets/images/onion.png',
      tag: '',
      bgColor: const Color(0xFFE8F5E9),
    ),
    VegetableProduct(
      id: 'v3',
      name: 'Potato',
      weight: '1.50 lbs',
      price: 9.90,
      imagePath: 'assets/images/potato.png',
      tag: '',
      bgColor: const Color(0xFFFFFDE7),
    ),
    VegetableProduct(
      id: 'v4',
      name: 'Carrot',
      weight: '5.0 lbs',
      price: 7.05,
      imagePath: 'assets/images/carrot.png',
      tag: '-16%',
      bgColor: const Color(0xFFFFF3E0),
    ),
  ];

  List<VegetableProduct> get vegetableProducts => _vegetableProducts;

  /// Load persistent data and align local state
  Future<void> loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

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

    await CartStorage.loadCart();

    for (var product in _vegetableProducts) {
      product.isFavorite = favoriteItems.any(
            (item) =>
        item['id']?.toString() == product.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    product.name.toLowerCase()),
      );

      final cartIndex = cartItems.indexWhere(
            (item) =>
        item['id']?.toString() == product.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    product.name.toLowerCase()),
      );

      if (cartIndex >= 0) {
        product.inCart = true;
        product.quantity = cartItems[cartIndex]['quantity'] ?? 1;
      } else {
        product.inCart = false;
        product.quantity = 1;
      }
    }

    notifyListeners();
  }

  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsJson = favoriteItems.map((item) {
      final Map<String, dynamic> savableMap = Map.from(item);
      savableMap.remove('bgColor');
      return jsonEncode(savableMap);
    }).toList();

    await prefs.setStringList(_favoritesKey, favsJson);
  }

  void toggleFavorite(VegetableProduct product) {
    product.isFavorite = !product.isFavorite;

    if (product.isFavorite) {
      final exists = favoriteItems.any(
            (item) =>
        item['id']?.toString() == product.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    product.name.toLowerCase()),
      );
      if (!exists) {
        favoriteItems.add({
          'id': product.id,
          'title': product.name,
          'unit': product.weight,
          'price': '\$${product.price.toStringAsFixed(2)}',
          'imagePath': product.imagePath,
        });
      }
    } else {
      favoriteItems.removeWhere(
            (item) =>
        item['id']?.toString() == product.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    product.name.toLowerCase()),
      );
    }

    _saveFavoritesToPrefs();

    try {
      final mainProduct = products.firstWhere(
            (p) =>
        p.id == product.id ||
            p.title.trim().toLowerCase() == product.name.trim().toLowerCase(),
      );
      mainProduct.isFavorite = product.isFavorite;
    } catch (_) {}

    notifyListeners();
  }

  void _syncToCart(VegetableProduct product) {
    final existingIndex = cartItems.indexWhere(
          (item) =>
      item['id']?.toString() == product.id ||
          (item['title'] != null &&
              item['title'].toString().toLowerCase() ==
                  product.name.toLowerCase()),
    );

    if (product.inCart) {
      final cartData = {
        'id': product.id,
        'title': product.name,
        'unitPrice': product.price,
        'price': '\$${product.price.toStringAsFixed(2)} x ${product.quantity}',
        'unit': product.weight,
        'quantity': product.quantity,
        'imagePath': product.imagePath,
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

    CartStorage.saveCart();

    try {
      final mainProduct = products.firstWhere(
            (p) =>
        p.id == product.id ||
            p.title.trim().toLowerCase() == product.name.trim().toLowerCase(),
      );
      mainProduct.inCart = product.inCart;
      mainProduct.quantity = product.quantity;
    } catch (_) {}
  }

  void addToCart(VegetableProduct product) {
    product.inCart = true;
    if (product.quantity < 1) {
      product.quantity = 1;
    }
    _syncToCart(product);
    notifyListeners();
  }

  void incrementCartQuantity(VegetableProduct product) {
    product.quantity++;
    _syncToCart(product);
    notifyListeners();
  }

  bool decrementCartQuantity(VegetableProduct product) {
    bool justRemoved = false;
    if (product.quantity > 1) {
      product.quantity--;
    } else {
      product.inCart = false;
      justRemoved = true;
    }
    _syncToCart(product);
    notifyListeners();
    return justRemoved;
  }
}
