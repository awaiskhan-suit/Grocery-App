import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'products_provider.dart';

class FavoritesProvider extends ChangeNotifier {
  // ======================================================
  // SHARED PREFERENCES KEY
  // ======================================================

  static const String _prefsKey = 'user_favorite_ids';

  // ======================================================
  // FAVORITE PRODUCT IDS
  // ======================================================

  final Set<String> _favoriteIds = {};

  // ======================================================
  // GETTERS
  // ======================================================

  List<String> get favoriteIds => _favoriteIds.toList();

  int get favoriteCount => _favoriteIds.length;

  // ======================================================
  // CONSTRUCTOR
  // ======================================================

  FavoritesProvider() {
    loadPersistedFavorites();
  }

  // ======================================================
  // LOAD FAVORITES FROM SHARED PREFERENCES
  // ======================================================

  Future<void> loadPersistedFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> savedFavorites =
          prefs.getStringList(_prefsKey) ?? [];

      _favoriteIds
        ..clear()
        ..addAll(savedFavorites);

      notifyListeners();

      debugPrint(
        'Favorites loaded successfully: ${_favoriteIds.length}',
      );
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // ======================================================
  // SAVE FAVORITES TO SHARED PREFERENCES
  // ======================================================

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(
        _prefsKey,
        _favoriteIds.toList(),
      );

      debugPrint(
        'Favorites saved successfully: ${_favoriteIds.length}',
      );
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // ======================================================
  // CHECK IF PRODUCT IS FAVORITE
  // ======================================================

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  // ======================================================
  // TOGGLE FAVORITE BY ID
  // ======================================================
  //
  // Use this when you only have the product ID.
  //
  // Example:
  //
  // await favoritesProvider.toggleFavoriteById(product.id);
  //
  // ======================================================

  Future<void> toggleFavoriteById(String id) async {
    if (_favoriteIds.contains(id)) {
      // Remove from favorites
      _favoriteIds.remove(id);

      debugPrint(
        'Removed favorite ID: $id',
      );
    } else {
      // Add to favorites
      _favoriteIds.add(id);

      debugPrint(
        'Added favorite ID: $id',
      );
    }

    notifyListeners();

    await _saveToPrefs();
  }

  // ======================================================
  // TOGGLE FAVORITE USING PRODUCT OBJECT
  // ======================================================

  Future<void> toggleFavorite(ProductItem product) async {
    final String id = product.id;

    if (_favoriteIds.contains(id)) {
      // Remove from favorites
      _favoriteIds.remove(id);

      product.isFavorite = false;

      debugPrint(
        'Removed from favorites: ${product.name}',
      );
    } else {
      // Add to favorites
      _favoriteIds.add(id);

      product.isFavorite = true;

      debugPrint(
        'Added to favorites: ${product.name}',
      );
    }

    notifyListeners();

    await _saveToPrefs();
  }

  // ======================================================
  // ADD FAVORITE
  // ======================================================

  Future<void> addFavorite(ProductItem product) async {
    final String id = product.id;

    if (!_favoriteIds.contains(id)) {
      _favoriteIds.add(id);

      product.isFavorite = true;

      notifyListeners();

      await _saveToPrefs();

      debugPrint(
        'Added favorite: ${product.name}',
      );
    }
  }

  // ======================================================
  // REMOVE FAVORITE
  // ======================================================

  Future<void> removeFavorite(ProductItem product) async {
    final String id = product.id;

    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);

      product.isFavorite = false;

      notifyListeners();

      await _saveToPrefs();

      debugPrint(
        'Removed favorite: ${product.name}',
      );
    }
  }

  // ======================================================
  // REMOVE FAVORITE BY ID
  // ======================================================

  Future<void> removeFavoriteById(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);

      notifyListeners();

      await _saveToPrefs();

      debugPrint(
        'Removed favorite ID: $id',
      );
    }
  }

  // ======================================================
  // CLEAR ALL FAVORITES
  // ======================================================

  Future<void> clearFavorites() async {
    _favoriteIds.clear();

    notifyListeners();

    await _saveToPrefs();

    debugPrint('All favorites cleared');
  }

  // ======================================================
  // GET FAVORITE PRODUCTS
  // ======================================================
  //
  // Converts favorite IDs into ProductItem objects.
  //
  // ======================================================

  List<ProductItem> getFavoriteProducts(
      ProductProvider productProvider,
      ) {
    return productProvider.allProducts
        .where(
          (product) => _favoriteIds.contains(product.id),
    )
        .toList();
  }

  // ======================================================
  // SYNC PRODUCTS WITH FAVORITES
  // ======================================================
  //
  // Makes ProductItem.isFavorite match FavoritesProvider.
  //
  // ======================================================

  void syncProducts(List<ProductItem> products) {
    for (final product in products) {
      product.isFavorite =
          _favoriteIds.contains(product.id);
    }

    notifyListeners();
  }
}
