import 'package:flutter/material.dart';

import 'product_provider.dart';
import 'favorites_provider.dart';

class FruitProvider extends ChangeNotifier {
  // ============================================================
  // FRUIT PRODUCTS
  // ============================================================

  final List<ProductItem> _fruitProducts = [
    ProductItem(
      id: 'f1',
      name: 'Fresh Peach',
      weight: 'dozen',
      price: 8.00,
      imagePath: 'assets/images/peach.jpg',
      tag: 'NEW',
      bgColor: const Color(0xFFFFF3E0),
      description:
      'Fresh and juicy organic peaches picked directly from the farm. Rich in vitamins and natural sweetness.',
      category: 'Fruits',
    ),

    ProductItem(
      id: 'f2',
      name: 'Avocado',
      weight: '2.0 lbs',
      price: 7.00,
      imagePath: 'assets/images/Avocado.jpg',
      tag: 'NEW',
      bgColor: const Color(0xFFE8F5E9),
      description:
      'Creamy, fresh Hass avocados packed with healthy fats and essential nutrients. Perfect for salads and toast.',
      category: 'Fruits',
    ),

    ProductItem(
      id: 'f3',
      name: 'Pineapple',
      weight: '1.50 lbs',
      price: 9.90,
      imagePath: 'assets/images/pinaple.jpg',
      tag: '',
      bgColor: const Color(0xFFFFFDE7),
      description:
      'Sweet and tropical ripe pineapples. High in vitamin C and perfect for refreshing juices and snacks.',
      category: 'Fruits',
    ),
  ];

  // ============================================================
  // GET FRUITS
  // ============================================================

  List<ProductItem> get fruitProducts => _fruitProducts;

  // ============================================================
  // TOGGLE FRUIT FAVORITE
  // ============================================================

  Future<void> toggleFruitFavorite(
      ProductItem fruit,
      FavoritesProvider favoritesProvider,
      ) async {
    await favoritesProvider.toggleFavoriteById(
      fruit.id,
    );

    fruit.isFavorite =
        favoritesProvider.isFavorite(fruit.id);

    notifyListeners();
  }

  // ============================================================
  // SYNC FAVORITE STATUS
  // ============================================================

  void syncFavoriteStatus(
      FavoritesProvider favoritesProvider,
      ) {
    for (final fruit in _fruitProducts) {
      fruit.isFavorite =
          favoritesProvider.isFavorite(fruit.id);
    }

    notifyListeners();
  }
}
