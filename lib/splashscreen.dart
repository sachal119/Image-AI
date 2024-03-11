import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:mathsolver/home.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: LottieBuilder.asset("assets/logo.json"),
            ),
          ],
        ),
      ),
      nextScreen: const MyHomePage(),
      backgroundColor: Colors.white,
      splashIconSize: 400,
    );
  }
}
