import 'dart:async';
import 'package:flutter/material.dart';
import 'final-eppointpent.dart';

class GreenSplashScreen extends StatefulWidget {
  const GreenSplashScreen({super.key});

  @override
  State<GreenSplashScreen> createState() => _GreenSplashScreenState();
}

class _GreenSplashScreenState extends State<GreenSplashScreen> {
  @override
  void initState() {
    super.initState();

    // get time
    Timer(const Duration(seconds: 2), () {
      // if Screen have after 3 seconds go next page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SuccessScreen(), //next page name
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //  for all Screen green
      backgroundColor: Color(0xFF66BB00),

    );
  }
}