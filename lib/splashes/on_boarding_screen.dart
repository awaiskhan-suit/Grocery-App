import 'package:flutter/material.dart';
import '../auth/auth1_welcome.dart';
import '../home/home_screen.dart';

// ======================================================
// 1. MODEL CLASS (same style as Category / Product)
// ======================================================
class SplashModel {
  final int id;
  final String title;
  final String description;
  final String image;

  SplashModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });
}

// ======================================================
// 2. LIST OF ALL SPLASH SCREENS (same style as categories / products)
// ======================================================
List<SplashModel> splashList = [
  SplashModel(
    id: 0,
    title: 'Premium Food\nAt Your Doorstep',
    description: 'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod',
    image: 'assets/images/screen1.webp',
  ),
  SplashModel(
    id: 1,
    title: 'Buy Premium\nQuality Fruits',
    description: 'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod',
    image: 'assets/images/ser1.jpg',
  ),
  SplashModel(
    id: 2,
    title: 'Buy Quality\nDairy Products',
    description: 'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod',
    image: 'assets/images/ser2.jpg',
  ),
  SplashModel(
    id: 3,
    title: 'Get Discount\nOn All Products',
    description: 'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod',
    image: 'assets/images/ser3.jpg',
  ),
];

// ======================================================
// 3. MAIN SCREEN THAT USES THE LIST
// ======================================================
class SplashOnboardingScreen extends StatefulWidget {
  const SplashOnboardingScreen({super.key});

  @override
  State<SplashOnboardingScreen> createState() => _SplashOnboardingScreenState();
}

class _SplashOnboardingScreenState extends State<SplashOnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentIndex < splashList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Auth1WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: splashList.length, // using list length
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          // Accessing each screen from the list
          final item = splashList[index];
          return SplashPage(item: item, currentIndex: currentIndex);
        },
      ),
    );
  }
}

// ======================================================
// 4. SINGLE PAGE WIDGET (uses data from list)
// ======================================================
class SplashPage extends StatelessWidget {
  final SplashModel item;
  final int currentIndex;

  const SplashPage({
    super.key,
    required this.item,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE9FFD9),
      body: SafeArea(
        child: Stack(
          children: [
            // Image from list
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.65,
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Bottom content
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.40,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Title from list
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description from list
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashList.length,
                            (index) => _dot(index == currentIndex),
                      ),
                    ),

                    const Spacer(),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final parent = context.findAncestorStateOfType<_SplashOnboardingScreenState>();
                          parent?.nextPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Get started',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF72CF2C) : const Color(0xFFD7D7D7),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}