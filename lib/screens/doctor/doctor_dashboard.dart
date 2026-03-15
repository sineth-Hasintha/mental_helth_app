import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorDashboard extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  final String uid;

  const DoctorDashboard({
    super.key,
    required this.doctorName,
    required this.doctorId,
    required this.uid,
  });

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Use logout to exit")));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red, size: 24),
              onPressed: _logout,
              tooltip: "Logout",
            ),
          ],
        ),
        body: _buildPage(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
          selectedFontSize: screenWidth * 0.03,
          unselectedFontSize: screenWidth * 0.03,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 26),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 28),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildAppointmentsPage();
      case 2:
        return _buildProfilePage();
      case 3:
        return _buildSettingsPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.02),

          // Welcome Message
          Text(
            "Welcome, Dr. ${widget.doctorName}",
            style: TextStyle(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          Text(
            "Have a great day!",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: screenHeight * 0.04),

          // Today's Appointments
          Text(
            "Today's Appointments",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          _buildTodayAppointments(),

          SizedBox(height: screenHeight * 0.04),

          // Recent Appointments
          Text(
            "Upcoming Appointments",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          _buildUpcomingAppointments(),

          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctor_email', isEqualTo: '')
          .where(
            'appointment_date',
            isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "No appointments for today",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            return _buildAppointmentCard(doc);
          }).toList(),
        );
      },
    );
  }

  Widget _buildUpcomingAppointments() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('doctor_email', isEqualTo: '')
          .orderBy('appointment_date')
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "No upcoming appointments",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            return _buildAppointmentCard(doc);
          }).toList(),
        );
      },
    );
  }

  Widget _buildAppointmentCard(DocumentSnapshot doc) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final data = doc.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['patient_name'] ?? 'Patient Name',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Pending",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Date: ${data['appointment_date'] ?? 'N/A'} | Time: ${data['appointment_time'] ?? 'N/A'}",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Issue: ${data['reason'] ?? 'No description'}",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsPage() {
    return const Center(child: Text("Appointments Page"));
  }

  Widget _buildProfilePage() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.03,
      ),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          Container(
            width: screenWidth * 0.25,
            height: screenWidth * 0.25,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/images/doctor.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            "Dr. ${widget.doctorName}",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "ID: ${widget.doctorId}",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          const Divider(),
          SizedBox(height: screenHeight * 0.02),
          _buildProfileInfoCard("Email", "doctor@example.com", Icons.email),
          _buildProfileInfoCard("Phone", "+94 71 234 5678", Icons.phone),
          _buildProfileInfoCard(
            "Specialization",
            "General Physician",
            Icons.medical_services,
          ),
          _buildProfileInfoCard("Experience", "5+ Years", Icons.work),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return const Center(child: Text("Settings Page"));
  }
}
