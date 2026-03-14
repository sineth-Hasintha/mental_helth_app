import 'package:flutter/material.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String selectedTab = "Pending";

  @override
  Widget build(BuildContext context) {
    // Screen size detect කිරීම
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.02),

        // --- Tab Selection Bar (Responsive) ---
        Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem("Pending", screenWidth),
              _buildTabItem("Confirmed", screenWidth),
              _buildTabItem("Completed", screenWidth),
              _buildTabItem("Cancelled", screenWidth),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.04),

        // --- Table Headers (Responsive Fonts) ---
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            children: [
              Expanded(
                  child: Text('Patient',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04
                      )
                  )
              ),
              Expanded(
                  child: Text('Doctor',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04
                      )
                  )
              ),
              Expanded(
                  child: Text('Date',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04
                      )
                  )
              ),
            ],
          ),
        ),

        const Divider(indent: 20, endIndent: 20), // Header එක යටින් පොඩි ඉරක්

        // --- Appointment List Items ---
        Expanded(
          child: _buildAppointmentList(screenWidth),
        ),
      ],
    );
  }

  Widget _buildAppointmentList(double screenWidth) {
    // තෝරාගත් ටැබ් එක අනුව පෙන්වන දත්ත
    List<Map<String, String>> data = [];

    if (selectedTab == "Pending") {
      data = [
        {"p": "Naduka Perera", "d": "Dr.Ranidu Dilmina", "t": "Mar 08, 2026"},
        {"p": "Sahan Silva", "d": "Dr.Pathum Nissanka", "t": "Mar 10, 2026"},
      ];
    } else if (selectedTab == "Confirmed") {
      data = [
        {"p": "Amal Perera", "d": "Dr.Nimal Perera", "t": "Mar 12, 2026"},
      ];
    }

    if (data.isEmpty) {
      return Center(child: Text("No $selectedTab Appointments"));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _buildAppointmentRow(
            data[index]["p"]!,
            data[index]["d"]!,
            data[index]["t"]!,
            screenWidth
        );
      },
    );
  }

  Widget _buildTabItem(String text, double screenWidth) {
    bool isActive = (selectedTab == text);
    // Screen එක ගොඩක් කුඩා නම් font size එක අඩු කිරීම
    double fontSize = screenWidth * 0.03 > 12 ? 12 : screenWidth * 0.03;

    return Expanded( // ටැබ් හතරම සමානව බෙදී යාමට
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentRow(String patient, String doctor, String date, double screenWidth) {
    double fontSize = screenWidth * 0.035 > 13 ? 13 : screenWidth * 0.035;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Expanded(child: Text(patient, style: TextStyle(fontSize: fontSize))),
          Expanded(child: Text(doctor, style: TextStyle(fontSize: fontSize), textAlign: TextAlign.center)),
          Expanded(child: Text(date, style: TextStyle(fontSize: fontSize), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}