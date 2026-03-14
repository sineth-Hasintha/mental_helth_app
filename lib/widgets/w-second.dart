import 'package:flutter/material.dart';

// --- 1. App Icon Widget ---

// --- 2. Gradient Circle Widget ---
class GradientCircle extends StatelessWidget {
  final double size;

  const GradientCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF5CD65C),
            Color(0xFF053B01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// --- 3. Custom Button (Full Width) ---
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF338B22),
  });

  @override
  Widget build(BuildContext context) {
    // Screen උස අනුව බටන් එකේ උස ඇජස්ට් කිරීම
    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity, // මුළු පළලම ගන්නවා, ඒක responsive වලට හොඳයි
      height: screenHeight * 0.065, // Screen height එකෙන් 6.5% ක් උස ගන්නවා
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // දාර ටිකක් වැඩියෙන් වටකුරු කළා
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// --- 4. Custom Button 1 (Responsive Width) ---
class CustomButton1 extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomButton1({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      // 250 කියන fixed අගය වෙනුවට screen width එකෙන් 70%ක් ගන්නවා
      width: screenWidth * 0.7,
      height: screenHeight * 0.065,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF33691E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}