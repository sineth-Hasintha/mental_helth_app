import 'package:flutter/material.dart';
import 'package:animated_calculator/widgets/w-second.dart';
import 'doctor-singin.dart';
import 'd-login.dart';


class WelcomeLoginPage extends StatelessWidget {
  const WelcomeLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // get screens width and height
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Background Circles (Responsive Position & Size) ---

          // upper right circle
          Positioned(
            top: -screenHeight * 0.05,
            right: -screenWidth * 0.1,
            child: GradientCircle(size: screenWidth * 0.55),
          ),

          // mid circle
          Positioned(
            top: screenHeight * 0.3,
            left: -screenWidth * 0.15,
            child: GradientCircle(size: screenWidth * 0.5),
          ),

          // under right circle
          Positioned(
            bottom: -screenHeight * 0.08,
            right: -screenWidth * 0.08,
            child: GradientCircle(size: screenWidth * 0.6),
          ),

          // --- Buttons Section ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Log in Button ---
                CustomButton1(
                  title: "Log in",
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const dlogin()),
                    );
                  },
                ),

                // space between button
                SizedBox(height: screenHeight * 0.10),

                // --- Sign up Button ---
                CustomButton1(
                  title: "Sign up",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DoctorRegistrationPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class ActualLoginPage extends StatelessWidget {
  const ActualLoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In Page")),
      body: const Center(child: Text("Welcome! Please Login")),
    );
  }
}