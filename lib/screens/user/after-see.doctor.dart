import 'package:flutter/material.dart';
import 'book-appointment.dart'; // ඔබ සාදාගත් BookAppointmentScreen එක ඇති ෆයිල් එක

class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. කලින් පිටුවෙන් (DoctorListScreen) එවන සියලුම දත්ත ලබා ගැනීම
    final Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // 2. Screen එකේ ප්‍රමාණයන් ලබා ගැනීම (Responsive UI සඳහා)
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // පසුබිමේ ඇති කොළ පැහැති රවුම්
          Positioned(
            right: -sWidth * 0.1,
            top: sHeight * 0.30,
            child: Container(
              width: sWidth * 0.6,
              height: sWidth * 0.6,
              decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.5),
                  shape: BoxShape.circle
              ),
            ),
          ),
          Positioned(
            right: sWidth * 0.5,
            top: sHeight * 0.8,
            child: Container(
              width: sWidth * 0.6,
              height: sWidth * 0.6,
              decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.5),
                  shape: BoxShape.circle
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                // ඉහළ පින්තූරය සහිත කොටස
                Stack(
                  children: [
                    Container(
                      height: sHeight * 0.4,
                      width: sWidth,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(200),
                            bottomRight: Radius.circular(200)
                        ),
                        border: Border.all(color: Colors.blue, width: sWidth * 0.005),
                        image: DecorationImage(
                          image: (data['Photo'] != null && data['Photo'] != "")
                              ? NetworkImage(data['Photo'])
                              : const NetworkImage('https://via.placeholder.com/150'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Back Button එක
                    Positioned(
                      top: sHeight * 0.05,
                      left: sWidth * 0.04,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: sWidth * 0.06),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sHeight * 0.03),

                // වෛද්‍යවරයාගේ නම පෙන්වීම
                Text(
                  "Dr. ${data['Full-Name'] ?? 'Unknown'}",
                  style: TextStyle(
                      fontSize: sWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700
                  ),
                ),

                // තරු ලකුණු (Rating)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: sWidth * 0.06,
                  )),
                ),

                // ඉරක් (Divider)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sWidth * 0.08, vertical: sHeight * 0.01),
                  child: const Divider(thickness: 1.5, color: Colors.grey),
                ),

                // About Section - වෛද්‍යවරයාගේ විස්තර
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sWidth * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("About", style: TextStyle(fontSize: sWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      SizedBox(height: sHeight * 0.01),
                      Text(
                        "Dr. ${data['Full-Name']} is a specialist in ${data['Specialization']}. Currently practicing in ${data['City'] ?? 'N/A'} with over ${data['Experience'] ?? '0'} years of experience.",
                        style: TextStyle(fontSize: sWidth * 0.04, height: 1.4),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sHeight * 0.04),

                // Book Appointment Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sWidth * 0.1),
                  child: ElevatedButton(
                    onPressed: () {
                      // මෙහිදී 'Full-Name' සහ 'Doctor-ID' යන දත්ත දෙකම BookAppointmentPage වෙත යවයි
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookAppointmentPage(
                            // දත්ත ලබාගෙන String වලට convert කර යැවීම
                            doctorName: (data['Full-Name'] ?? 'Unknown').toString(),
                            doctorId: (data['Doctor-ID'] ?? '').toString(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5DB004),
                      minimumSize: Size(double.infinity, sHeight * 0.065),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sWidth * 0.08)),
                    ),
                    child: Text(
                        "Book Appointment",
                        style: TextStyle(color: Colors.white, fontSize: sWidth * 0.045, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                SizedBox(height: sHeight * 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}