import 'package:animated_calculator/widgets/w-second.dart';
import 'home.dart';
import 'package:flutter/material.dart';


class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //get Screen width and height
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          //  responsive space
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2), // upper space

              //  middle Image (t.png)
              Image.asset(
                'assets/images/t.png',
                width: screenWidth * 0.4,
                fit: BoxFit.contain,
              ),

              SizedBox(height: screenHeight * 0.05),

              // Title
              Text(
                "Successful",
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Description
              Text(
                "Your Appointment is Booked Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.black54,
                  height: 1.5, // space between row
                ),
              ),

              const Spacer(flex: 2),


              CustomButton(
                text: "continue",

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}