import 'package:flutter/material.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen එකේ size එක ලබා ගැනීම
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // Screen height එකෙන් 2% ක පරතරයක්
        SizedBox(height: screenHeight * 0.02),
        Text(
          'Total Users',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            // Screen width එක අනුව font size එක වෙනස් වීම
            fontSize: screenWidth * 0.06 > 24 ? 24 : screenWidth * 0.06,
          ),
        ),
        SizedBox(height: screenHeight * 0.03),

        Container(
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015,
              horizontal: screenWidth * 0.02
          ),
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            children: [
              _buildUserRow(context, "Dr.Nimal Perera", "Doctor", "Pending", Colors.orange),
              _buildUserRow(context, "Hirun Vihanga", "User", "Active", Colors.green),
              _buildUserRow(context, "Dr.Ranidu dilmina", "Doctor", "Approved", Colors.green),
              _buildUserRow(context, "Sineth Dilhara", "user", "inactive", Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserRow(BuildContext context, String name, String role, String status, Color statusColor) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.015,
          horizontal: screenWidth * 0.02
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  "${name.toLowerCase().replaceAll(' ', '')}@gmail.com",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(role)),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(radius: screenWidth * 0.012 > 5 ? 5 : screenWidth * 0.012, backgroundColor: statusColor),
                SizedBox(width: screenWidth * 0.01),
                Text(status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}