import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grocery/home/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites.dart';
import 'home_screen.dart';
import 'shopping_cart.dart';

class FruitProduct {
  final String id;
  final String name;
  final String weight;
  final double price;
  final String imagePath;
  final String tag;
  final Color bgColor;
  final String description;
  bool isFavorite;
  bool inCart;
  int quantity;

  FruitProduct({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.imagePath,
    required this.tag,
    required this.bgColor,
    required this.description,
    this.isFavorite = false,
    this.inCart = false,
    this.quantity = 1,
  });
}

class FruitProvider with ChangeNotifier {
  static const String _favoritesKey = 'saved_favorites';

  final List<FruitProduct> _fruitProducts = [
    FruitProduct(
      id: 'h0',
      name: 'Fresh Peach',
      weight: 'dozen',
      price: 8.00,
      imagePath: 'assets/images/peach.jpg',
      tag: 'NEW',
      bgColor: const Color(0xFFFFF3E0),
      description:
      'Fresh and juicy organic peaches picked directly from the farm. Rich in vitamins and natural sweetness.',
    ),
    FruitProduct(
      id: 'h1',
      name: 'Avocado',
      weight: '2.0 lbs',
      price: 7.00,
      imagePath: 'assets/images/Avocado.jpg',
      tag: 'NEW',
      bgColor: const Color(0xFFE8F5E9),
      description:
      'Creamy, fresh Hass avocados packed with healthy fats and essential nutrients. Perfect for salads and toast.',
    ),
    FruitProduct(
      id: 'h2',
      name: 'Pineapple',
      weight: '1.50 lbs',
      price: 9.90,
      imagePath: 'assets/images/pinaple.jpg',
      tag: '',
      bgColor: const Color(0xFFFFFDE7),
      description:
      'Sweet and tropical ripe pineapples. High in vitamin C and perfect for refreshing juices and snacks.',
    ),
  ];

  List<FruitProduct> get fruitProducts => _fruitProducts;

  /// Load persistent data and synchronize local state
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

    for (var fruit in _fruitProducts) {
      fruit.isFavorite = favoriteItems.any(
            (item) =>
        item['id']?.toString() == fruit.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    fruit.name.toLowerCase()),
      );

      final cartIndex = cartItems.indexWhere(
            (item) =>
        item['id']?.toString() == fruit.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    fruit.name.toLowerCase()),
      );

      if (cartIndex >= 0) {
        fruit.inCart = true;
        fruit.quantity = cartItems[cartIndex]['quantity'] ?? 1;
      } else {
        fruit.inCart = false;
        fruit.quantity = 1;
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

  void toggleFruitFavorite(FruitProduct fruit) {
    fruit.isFavorite = !fruit.isFavorite;

    if (fruit.isFavorite) {
      final exists = favoriteItems.any(
            (item) =>
        item['id']?.toString() == fruit.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    fruit.name.toLowerCase()),
      );
      if (!exists) {
        favoriteItems.add({
          'id': fruit.id,
          'title': fruit.name,
          'unit': fruit.weight,
          'price': '\$${fruit.price.toStringAsFixed(2)}',
          'imagePath': fruit.imagePath,
        });
      }
    } else {
      favoriteItems.removeWhere(
            (item) =>
        item['id']?.toString() == fruit.id ||
            (item['title'] != null &&
                item['title'].toString().toLowerCase() ==
                    fruit.name.toLowerCase()),
      );
    }

    _saveFavoritesToPrefs();

    try {
      final mainProduct = products.firstWhere(
            (p) =>
        p.id.toString() == fruit.id.toString() ||
            p.title.trim().toLowerCase() == fruit.name.trim().toLowerCase(),
      );
      mainProduct.isFavorite = fruit.isFavorite;
    } catch (_) {}

    notifyListeners();
  }

  void _syncFruitToCart(FruitProduct fruit) {
    final existingIndex = cartItems.indexWhere(
          (item) =>
      item['id']?.toString() == fruit.id ||
          (item['title'] != null &&
              item['title'].toString().toLowerCase() ==
                  fruit.name.toLowerCase()),
    );

    if (fruit.inCart) {
      final cartData = {
        'id': fruit.id,
        'title': fruit.name,
        'unitPrice': fruit.price,
        'price': '\$${fruit.price.toStringAsFixed(2)} x ${fruit.quantity}',
        'unit': fruit.weight,
        'quantity': fruit.quantity,
        'imagePath': fruit.imagePath,
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
        p.id.toString() == fruit.id.toString() ||
            p.title.trim().toLowerCase() == fruit.name.trim().toLowerCase(),
      );
      mainProduct.inCart = fruit.inCart;
      mainProduct.quantity = fruit.quantity;
    } catch (_) {}
  }

  void addFruitToCart(FruitProduct fruit) {
    fruit.inCart = true;
    if (fruit.quantity < 1) {
      fruit.quantity = 1;
    }
    _syncFruitToCart(fruit);
    notifyListeners();
  }

  void incrementFruitCartQuantity(FruitProduct fruit) {
    fruit.quantity++;
    _syncFruitToCart(fruit);
    notifyListeners();
  }

  bool decrementFruitCartQuantity(FruitProduct fruit) {
    bool justRemoved = false;
    if (fruit.quantity > 1) {
      fruit.quantity--;
    } else {
      fruit.inCart = false;
      justRemoved = true;
    }
    _syncFruitToCart(fruit);
    notifyListeners();
    return justRemoved;
  }
}
