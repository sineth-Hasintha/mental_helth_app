import 'package:flutter/material.dart';
import 'package:animated_calculator/widgets/w-second.dart';
import 'doctor-log-sing-selecte.dart';
import 'u-fist.dart';

import  'admin_login.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    // get screens width and height
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Background Gradient Circles (Responsive) ---

          // up right circles
          Positioned(
            top: -screenHeight * 0.06,
            right: -screenWidth * 0.15,
            child: GradientCircle(size: screenWidth * 0.65), // Screen width එකෙන් 65% ක්
          ),

          // mid left circles
          Positioned(
            top: screenHeight * 0.35,
            left: -screenWidth * 0.2,
            child: GradientCircle(size: screenWidth * 0.7),
          ),

          // under right circles
          Positioned(
            bottom: -screenHeight * 0.08,
            right: -screenWidth * 0.1,
            child: GradientCircle(size: screenWidth * 0.68),
          ),

          // --- Main Buttons Section ---
          Center(
            child: SingleChildScrollView( // for 3 button  scroll safe
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // User Button
                  CustomButton1(
                    title: "User",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomePage()),
                      );
                    },
                  ),

                  // height for between button
                  SizedBox(height: screenHeight * 0.06),

                  // Doctor Button
                  CustomButton1(
                    title: "Doctor",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeLoginPage()),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // Admin Button
                  CustomButton1(
                    title: "Admin",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

