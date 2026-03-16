import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDashboardPage extends StatefulWidget {
  final String doctorName; // Doctor ගේ නම ලබා ගැනීමට

  const DoctorDashboardPage({super.key, required this.doctorName});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // අවශ්‍ය නම් මෙතනින් වෙනත් pages වලට navigate කරන්න (උදා: appointments page එකට)
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: screenWidth * 0.055),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor ගේ නම පෙන්වන කොටස
            Text(
              "Hello, Dr. ${widget.doctorName}",
              style: TextStyle(
                fontSize: screenWidth * 0.065,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // පළමු පේළිය (Pending Appointments & Total Patients)
            Row(
              children: [
                _buildDashboardCard(
                  title: "Pending\nAppointments",
                  icon: Icons.pending_actions,
                  backgroundColor: const Color(0xFF8BBCE5), // Light Blue
                  textColor: Colors.black,
                  // මෙහිදී 'status' එක 'pending' වන appointments පමණක් ගණනය කරයි
                  stream: FirebaseFirestore.instance.collection('appointments').where('status', isEqualTo: 'pending').snapshots(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                _buildDashboardCard(
                  title: "Total\nPatients",
                  icon: Icons.person,
                  backgroundColor: const Color(0xFFA5E364), // Light Green
                  textColor: Colors.black,
                  // දැනට සාමාන්‍ය users ලා ගණන පෙන්වීමට දමා ඇත (අවශ්‍ය නම් වෙනස් කරගන්න)
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            // දෙවන පේළිය (Active Time & Total Appointments)
            Row(
              children: [
                _buildDashboardCard(
                  title: "Active\nTime",
                  icon: Icons.access_time_filled, // Admin icons වලට ගැලපෙන time icon එකක්
                  backgroundColor: const Color(0xFFEED16C), // Yellow
                  textColor: Colors.black,
                  staticValue: "8h", // මෙය Database එකෙන් නොඑන නිසා දැනට "8h" ලෙස static දී ඇත
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                _buildDashboardCard(
                  title: "\nAppoinments",
                  icon: Icons.calendar_month,
                  backgroundColor: const Color(0xFF1E75FB), // Dark Blue
                  textColor: Colors.white,
                  stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar (Admin එකේ යොදාගත් Icons ම භාවිතා කර ඇත)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        selectedFontSize: screenWidth * 0.03,
        unselectedFontSize: screenWidth * 0.03,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today, size: 26), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services, size: 28), label: 'Doctors'),
        ],
      ),
    );
  }

  // Cards නිර්මාණය කිරීම සඳහා භාවිත කරන පොදු Widget එක
  // මෙහිදී Database එකේ (Stream) අගයක් හෝ සාමාන්‍ය (staticValue) අගයක් පෙන්වීමට හැකි ලෙස සකසා ඇත.
  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Stream<QuerySnapshot>? stream, // Database එකෙන් එන data
    String? staticValue, // සාමාන්‍ය අකුරු (උදා: "8h")
    required double screenWidth,
    required double screenHeight,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: screenHeight * 0.18,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: textColor, size: screenWidth * 0.05),
                    SizedBox(width: screenWidth * 0.01),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Static Value එකක් දීලා තියෙනවා නම් ඒක පෙන්වනවා (උදා: "8h")
                if (staticValue != null)
                  Text(
                    staticValue,
                    style: TextStyle(
                      color: textColor,
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                // නැත්නම් Database එකෙන් එන ගණන පෙන්වනවා
                else if (stream != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: stream,
                    builder: (context, snapshot) {
                      String count = "0";
                      if (snapshot.hasData) {
                        count = snapshot.data!.docs.length.toString();
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        count = "...";
                      }
                      return Text(
                        count,
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.065,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}