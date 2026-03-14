import 'package:animated_calculator/screens/admin/Doctor_list_page.dart';
import 'package:flutter/material.dart';
import 'user_list_page.dart';
import 'Appoinment_pending_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screen size detect කිරීම
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> _pages = [
      HomeScreen(onTotalUsersTap: () => _onItemTapped(1)),
      const UserListPage(),
      const AppointmentPage(),
      const DoctorListPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: screenWidth * 0.05),
          onPressed: () {
            if (_selectedIndex == 0) {
              Navigator.pop(context);
            } else {
              setState(() {
                _selectedIndex = 0;
              });
            }
          },
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 1)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF338B22),
          unselectedItemColor: Colors.grey,
          // Tablet වලදී labels ඕනෑවට වඩා ලොකු වීම වැළැක්වීමට
          selectedLabelStyle: TextStyle(fontSize: screenWidth * 0.03 > 14 ? 14 : screenWidth * 0.03),
          unselectedLabelStyle: TextStyle(fontSize: screenWidth * 0.03 > 12 ? 12 : screenWidth * 0.03),
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/Home.png', screenWidth),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/User.png', screenWidth),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/Appoinment.png', screenWidth),
              label: 'Appoinments',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('assets/images/Doctor.png', screenWidth),
              label: 'Doctors',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String imagePath, double screenWidth) {
    // Icon size එක screen width එකෙන් 6% ක් ලෙස (උපරිමය 26)
    double iconSize = screenWidth * 0.065 > 26 ? 26 : screenWidth * 0.065;
    return Image.asset(
      imagePath,
      width: iconSize,
      height: iconSize,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onTotalUsersTap;

  const HomeScreen({super.key, required this.onTotalUsersTap});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView( // Screen එක කුඩා වුවහොත් scroll කිරීමට
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onTotalUsersTap,
                  child: _buildStatCard(
                    icon: Icons.person,
                    title: 'Total\nUsers',
                    value: '87',
                    color: const Color(0xFF91C3E8),
                    screenWidth: screenWidth,
                  ),
                ),
                _buildStatCard(
                  icon: Icons.person_add_alt_1,
                  title: 'Total\nDoctors',
                  value: '20',
                  color: const Color(0xFFC3EE85),
                  screenWidth: screenWidth,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // Row අතර පරතරය
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  icon: Icons.pending_actions,
                  title: 'Pending\nApprovals',
                  value: '7',
                  color: const Color(0xFFEDD187),
                  screenWidth: screenWidth,
                ),
                _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'Appointment',
                  value: '18',
                  color: const Color(0xFF2196F3),
                  textColor: Colors.white,
                  screenWidth: screenWidth,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double screenWidth,
    Color textColor = Colors.black,
  }) {
    // Card එකේ size එක screen width එකෙන් 42% ක් ලෙස
    double cardWidth = screenWidth * 0.42;

    return Container(
      width: cardWidth,
      // Card එක හතරැස්ව තබා ගැනීමට (Aspect Ratio)
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth * 0.08 > 30 ? 30 : screenWidth * 0.08, color: textColor),
          SizedBox(height: screenWidth * 0.02),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: screenWidth * 0.08 > 32 ? 32 : screenWidth * 0.08,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}