import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 4),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ⭐ Lottie Animation
            Lottie.asset(
              "assets/lottie/splash.json",
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            // ⭐ Main Logo Text (your color)
            const Text(
              "BabyShopHub",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF7C9D1),
                letterSpacing: 2,
              ),
            ),

            SizedBox(height: 8),

            // ⭐ Optional Beautiful Subtext
            Text(
              "Everything for your little one",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey, // Soft beautiful secondary font color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
