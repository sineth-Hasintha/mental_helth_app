import 'dart:async';
import 'package:flutter/material.dart';

import 'Third.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();

    // 3 seconds delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ThirdPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/fist.png', // ඔයාගේ image path එක
              width: 80,
              height: 80,
            ),

            const SizedBox(height: 10),

            const Text(
              "Mindspace",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold, // Text eka thawa lassanata damma
              ),
            ),
          ],
        ),
      ),
    );
  }
}