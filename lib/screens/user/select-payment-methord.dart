import 'package:flutter/material.dart';
// මෙහි ඔබගේ CustomButton එක ඇති path එක නිවැරදිව ඇතුළත් කරන්න
import 'package:animated_calculator/widgets/w-second.dart';
import 'book-appointment.dart';
import 'bank_ditails.dart'; // File name එක නිවැරදි දැයි බලන්න (Details විය යුතුයි)

class PaymentSelectionPage extends StatelessWidget {
  final String doctorName;
  final String doctorId;

  const PaymentSelectionPage({
    super.key,
    required this.doctorName,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ඉහළ දකුණු පස ඇති රවුම
          Positioned(
            top: -sHeight * 0.05,
            right: -sWidth * 0.15,
            child: Container(
              width: sWidth * 0.6,
              height: sWidth * 0.6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF5DB004), Color(0xFF83D42B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // පහළ වම් පස ඇති රවුම
          Positioned(
            bottom: -sHeight * 0.1,
            left: -sWidth * 0.2,
            child: Container(
              width: sWidth * 0.7,
              height: sWidth * 0.7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF5DB004), Color(0xFF83D42B)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
            ),
          ),

          // මැද ඇති බොත්තම් දෙක
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // පළමු බොත්තම
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sWidth * 0.05),
                  child: CustomButton(
                    text: "After meeting the doctor",
                    onPressed: () {
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

                SizedBox(height: sHeight * 0.04),

                // දෙවන බොත්තම (Online transfer)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sWidth * 0.05),
                  child: CustomButton(
                    text: "Online transfer",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // මෙතැනදී ඔබ කලින් කී පරිදි බැංකු විස්තර පිටුවට යාමට අවශ්‍ය නම් එය වෙනස් කළ හැක
                          builder: (context) => OnlineTransferPage(
                            doctorName: doctorName,
                            doctorId: doctorId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ], // Column Children Close
            ), // Column Close
          ), // Center Close
        ], // Stack Children Close
      ), // Stack Close
    ); // Scaffold Close
  }
}