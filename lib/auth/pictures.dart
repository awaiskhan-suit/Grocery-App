import 'package:flutter/material.dart';

/// Top image section shared by the Welcome and Login screens:
/// background photo, back button, and centered title.
class AuthHero extends StatelessWidget {
  final String title;

  const AuthHero({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ==== ADD YOUR IMAGE HERE ====
          // Replace this Container with your own image, e.g.:
          Image.asset('assets/images/ser67.jpg',

          ),
          // or Image.network('https://your-image-url.jpg', fit: BoxFit.cover),
          Container(
            color: const Color(0xFF3A3A40),
            child: const Center(
              child: Text(
                '',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ),

          // Subtle dark gradient so the status bar / title stay readable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 14,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),

          Positioned(
            top: 58,
            left: 0,
            right: 0,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}