import 'package:flutter/material.dart';

// ======================================================
// UNIFIED PRODUCT MODEL
// ======================================================

class ProductItem {
  final String id;
  final String name;
  final String weight;
  final double price;
  final String imagePath;
  final String tag;
  final Color bgColor;
  final String description;
  final String category;

  bool isFavorite;
  bool inCart;
  int quantity;

  ProductItem({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.imagePath,
    required this.tag,
    required this.bgColor,
    this.description = '',
    this.category = 'General',
    this.isFavorite = false,
    this.inCart = false,
    this.quantity = 1,
  });
}

// ======================================================
// LEGACY TYPEDEFS
// ======================================================

typedef VegetableProduct = ProductItem;
typedef FruitProduct = ProductItem;

// ======================================================
// PRODUCT PROVIDER
// ======================================================

class ProductProvider with ChangeNotifier {
  // ======================================================
  // PRODUCTS
  // ======================================================

  final List<ProductItem> _productsList = [
    // --------------------------------------------------
    // VEGETABLES
    // --------------------------------------------------

    ProductItem(
      id: 'v1',
      name: 'Tomato',
      weight: 'dozen',
      price: 8.00,
      imagePath: 'assets/images/tomato.png',
      tag: 'NEW',
      bgColor: const Color(0xFFFFEBEE),
      category: 'Vegetables',
    ),

    ProductItem(
      id: 'v2',
      name: 'Onion',
      weight: '2.0 lbs',
      price: 7.00,
      imagePath: 'assets/images/onion.png',
      tag: '',
      bgColor: const Color(0xFFE8F5E9),
      category: 'Vegetables',
    ),

    ProductItem(
      id: 'v3',
      name: 'Potato',
      weight: '1.50 lbs',
      price: 9.90,
      imagePath: 'assets/images/potato.png',
      tag: '',
      bgColor: const Color(0xFFFFFDE7),
      category: 'Vegetables',
    ),

    ProductItem(
      id: 'v4',
      name: 'Carrot',
      weight: '5.0 lbs',
      price: 7.05,
      imagePath: 'assets/images/carrot.png',
      tag: '-16%',
      bgColor: const Color(0xFFFFF3E0),
      category: 'Vegetables',
    ),

    // --------------------------------------------------
    // FRUITS
    // --------------------------------------------------

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

  // ======================================================
  // GETTERS
  // ======================================================

  List<ProductItem> get allProducts => _productsList;

  List<ProductItem> get vegetableProducts {
    return _productsList
        .where((product) => product.category == 'Vegetables')
        .toList();
  }

  List<ProductItem> get fruitProducts {
    return _productsList
        .where((product) => product.category == 'Fruits')
        .toList();
  }

  // ======================================================
  // SYNC FAVORITE STATUS
  // ======================================================
  //
  // FavoritesProvider uses this method to synchronize
  // the favorite state of ProductItem objects.
  //
  // ======================================================

  void syncFavoriteStatus(Set<String> favoriteIds) {
    for (final product in _productsList) {
      product.isFavorite = favoriteIds.contains(product.id);
    }

    notifyListeners();
  }

  // ======================================================
  // FIND PRODUCT BY ID
  // ======================================================

  ProductItem? getProductById(String id) {
    try {
      return _productsList.firstWhere(
            (product) => product.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ======================================================
  // SYNC CART STATUS
  // ======================================================
  //
  // CartProvider uses this method to synchronize the
  // inCart and quantity values of ProductItem objects.
  //
  // ProductProvider does NOT manage the cart.
  //
  // ======================================================

  void syncCartStatus(
      Set<String> cartIds,
      Map<String, int> quantities,
      ) {
    for (final product in _productsList) {
      if (cartIds.contains(product.id)) {
        product.inCart = true;
        product.quantity = quantities[product.id] ?? 1;
      } else {
        product.inCart = false;
        product.quantity = 1;
      }
    }

    notifyListeners();
  }
}
