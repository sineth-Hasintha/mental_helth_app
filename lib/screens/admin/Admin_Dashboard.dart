import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_doctor_approval.dart'; // Pending page එකට යන්න මේක import කරන්න (ඔබගේ path එක නිවැරදිව දෙන්න)

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // Bottom Navigation Bar එකේ බටන් click කරාම වෙනස් වෙන්න
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // අවශ්‍ය නම් මෙතනින් වෙනත් pages වලට navigate කරන්න පුළුවන්
    // උදා: index == 3 නම් Doctor list එකට යන්න.
  }

  @override
  Widget build(BuildContext context) {
    // Screen එකේ පළල සහ උස ලබාගැනීම
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: screenWidth * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),

            // පළමු පේළිය (Total Users & Total Doctors)
            Row(
              children: [
                _buildDashboardCard(
                  title: "Total\nUsers",
                  icon: Icons.person,
                  backgroundColor: const Color(0xFF8BBCE5), // Light Blue
                  textColor: Colors.black,
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
                _buildDashboardCard(
                  title: "Total\nDoctors",
                  icon: Icons.medical_services_outlined,
                  backgroundColor: const Color(0xFFA5E364), // Light Green
                  textColor: Colors.black,
                  // Approve වුනු Doctors ලා ගණන පමණක් ගණනය කිරීම
                  stream: FirebaseFirestore.instance
                      .collection('doctors')
                      .where('status', isEqualTo: 'approved')
                      .snapshots(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            // දෙවන පේළිය (Pending Approvals & Appointments)
            Row(
              children: [
                _buildDashboardCard(
                  title: "Pending\nApprovals",
                  icon: Icons.pending_actions,
                  backgroundColor: const Color(0xFFEED16C), // Yellow/Orange
                  textColor: Colors.black,
                  // Pending තත්වයේ සිටින Doctors ලා ගණන
                  stream: FirebaseFirestore.instance
                      .collection('doctors')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  onTap: () {
                    // Pending කාඩ් එක click කරාම අලුතෙන් හැදුව Admin Approval Page එකට යනවා
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDoctorApprovalPage(),
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  title:
                      "\nAppoinment", // Appoinment කියන එක පල්ලෙහායින් පෙන්වන්න \n එකක් දැම්මා
                  icon: Icons.calendar_month,
                  backgroundColor: const Color(0xFF1E75FB), // Blue
                  textColor: Colors.white,
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .snapshots(),
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.04),

            // Approved Doctors Section
            Text(
              "Approved Doctors",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            _buildApprovedDoctorsTable(screenWidth, screenHeight),
          ],
        ),
        ),
      ),

      // Bottom Navigation Bar
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 26),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services, size: 28),
            label: 'Doctors',
          ),
        ],
      ),
    );
  }

  // Cards නිර්මාණය කිරීම සඳහා භාවිත කරන පොදු Widget එක (Reusable Component)
  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Stream<QuerySnapshot> stream,
    required double screenWidth,
    required double screenHeight,
    VoidCallback? onTap, // Card එක click කරන්න පුළුවන් වෙන්න
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: screenHeight * 0.18, // Card එකේ උස
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12), // Corners රවුම් කිරීම
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              String count = "0"; // Default අගය

              // Database එකෙන් data ආවොත් ඒ ගණන පෙන්වීම
              if (snapshot.hasData) {
                count = snapshot.data!.docs.length.toString();
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                count = "..."; // Load වෙන වෙලාවට පෙන්වන දේ
              }

              return Padding(
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
                    Text(
                      count,
                      style: TextStyle(
                        color: textColor,
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Approved Doctors Table
  Widget _buildApprovedDoctorsTable(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.35,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No approved doctors",
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            );
          }

          final doctors = snapshot.data!.docs;

          return Column(
            children: [
              // Table Headers
              Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.015),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Name",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Specialization",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Status",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Table Rows
              Expanded(
                child: ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    var doc = doctors[index];
                    String name = doc['Full-Name'] ?? 'Unknown';
                    String specialization = doc['Specialization'] ?? 'General';

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.012),
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.white : Colors.grey[50],
                        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Dr. $name",
                              style: TextStyle(fontSize: screenWidth * 0.032),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              specialization,
                              style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.black54),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF65B741),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "✓",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
