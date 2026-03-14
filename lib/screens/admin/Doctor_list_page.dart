import 'package:flutter/material.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  String selectedTab = "Pending";

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.02),

        // Approve/Reject Legend
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            children: [
              _buildIndicator(Colors.green, "= Approve", screenWidth),
              SizedBox(width: screenWidth * 0.05),
              _buildIndicator(Colors.red, "= Reject", screenWidth),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        // Tab Selection
        Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Expanded(child: _buildTabItem("Pending")),
              Expanded(child: _buildTabItem("Confirmed")),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.03),

        // Table Headers
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text('Specialization', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Stats', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
            ],
          ),
        ),

        Expanded(
          child: _buildDoctorList(),
        ),
      ],
    );
  }

  Widget _buildDoctorList() {
    if (selectedTab == "Pending") {
      return ListView(
        children: [
          _buildDoctorRow("Dr.Kasun Rajapaksha", "Clinical Psychologist"),
        ],
      );
    } else {
      return const Center(child: Text("No Confirmed Doctors Found"));
    }
  }

  Widget _buildTabItem(String text) {
    bool isActive = (selectedTab == text);
    return GestureDetector(
      onTap: () => setState(() => selectedTab = text),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDoctorRow(String name, String spec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _showDoctorDetails(name, spec),
              child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline
                  )
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(spec, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _showActionSnackBar(name, "Approved"),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.check, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showActionSnackBar(name, "Rejected"),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorDetails(String name, String spec) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF338B22),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(spec, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                _buildDetailRow(Icons.badge, "Doctor ID", "DOC-2026-001"),
                _buildDetailRow(Icons.email, "Email Address", "kasun.r@gmail.com"),
                _buildDetailRow(Icons.phone, "Phone Number", "+94 77 123 4567"),
                _buildDetailRow(Icons.medical_services, "Specialization", spec),
                _buildDetailRow(Icons.assignment_ind, "SLMC Number", "SLMC/REG/8842"),
                _buildDetailRow(Icons.history, "Experience", "10 Years"),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF338B22),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF338B22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionSnackBar(String name, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$name has been $action")),
    );
  }

  Widget _buildIndicator(Color color, String text, double screenWidth) {
    return Row(
      children: [
        Container(width: screenWidth * 0.1, height: 8, color: color),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}