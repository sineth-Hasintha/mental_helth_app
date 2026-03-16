import 'package:flutter/material.dart';
// ඔබගේ CustomButton එක ඇති path එක නිවැරදිව ඇතුළත් කරන්න
import 'package:animated_calculator/widgets/w-second.dart';
import 'book-appointment.dart';

class OnlineTransferPage extends StatelessWidget {
  // දත්ත තිරයේ පෙන්වන්නේ නැතිව (Hidden) තබා ගැනීමට
  final String doctorName;
  final String doctorId;

  const OnlineTransferPage({
    super.key,
    required this.doctorName,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    // Screen එකේ ප්‍රමාණය ලබා ගැනීම (Responsive Design)
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ඉහළ දකුණු පස ඇති රවුම
          Positioned(
            top: -sHeight * 0.09,
            right: -sWidth * 0.2,
            child: Container(
              width: sWidth * 0.55,
              height: sWidth * 0.55,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF5DB004), Color(0xFF83D42B)],
                ),
              ),
            ),
          ),

          // මැද වම් පස ඇති රවුම
          Positioned(
            top: sHeight * 0.2,
            left: -sWidth * 0.3,
            child: Container(
              width: sWidth * 0.6,
              height: sWidth * 0.6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF5DB004), Color(0xFF83D42B)],
                ),
              ),
            ),
          ),

          // පහළ ඇති රවුම
          Positioned(
            bottom: -sHeight * 0.04,
            left: -sWidth * 0.2,
            child: Container(
              width: sWidth * 0.5,
              height: sWidth * 0.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF5DB004), Color(0xFF83D42B)],
                ),
              ),
            ),
          ),

          // Back Arrow (ඉහළ වම් පස)
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // බැංකු විස්තර පෙන්වන කොටස
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Bank = BOC",
                  style: TextStyle(fontSize: 22, color: Colors.black87),
                ),
                const Text(
                  "Ecount number = 1158573",
                  style: TextStyle(fontSize: 22, color: Colors.black87),
                ),
                const Text(
                  "Name = meantal health",
                  style: TextStyle(fontSize: 22, color: Colors.black87),
                ),

                SizedBox(height: sHeight * 0.1), // බොත්තමට ඉහළින් පරතරය

                // Go Back බොත්තම
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sWidth * 0.1),
                  child: CustomButton(
                    text: "go back",
                    onPressed: () {
                      // මෙහිදී දත්ත රැගෙන නැවත Appointment පිටුවට යයි
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookAppointmentPage(
                            doctorName: doctorName,
                            doctorId: doctorId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}