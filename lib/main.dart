import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grocery/providers/category_provider.dart';
import 'package:provider/provider.dart';

// Splash / Initial Screen
import 'package:grocery/splashes/on_boarding_screen.dart';

// Providers
import 'providers/product_provider.dart';
import 'providers/fruit_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/cart_provider.dart'; // ← Added

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        // Product Provider
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),

        // Fruit Provider
        ChangeNotifierProvider(
          create: (_) => FruitProvider(),
        ),

        // Favorites Provider
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(),
        ),

        // Cart Provider (Important)
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),

        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color brandGreen = Color(0xFF7AC142);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grocery App',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: brandGreen,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen,
          primary: brandGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashOnboardingScreen(),
    );
  }
}
