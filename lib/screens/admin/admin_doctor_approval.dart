import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDoctorApprovalPage extends StatefulWidget {
  const AdminDoctorApprovalPage({super.key});

  @override
  State<AdminDoctorApprovalPage> createState() => _AdminDoctorApprovalPageState();
}

class _AdminDoctorApprovalPageState extends State<AdminDoctorApprovalPage> {
  bool isPendingTab = true;

  Future<void> _updateDoctorStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('doctors').doc(docId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Doctor successfully $newStatus!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen එකේ පළල සහ උස ලබාගැනීම (Responsive කිරීම සඳහා)
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
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Screen එකේ පළලින් 5% ක Padding එකක්
        child: Column(
          children: [
            // Legend එක (Approve සහ Reject)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.08, 
                  height: screenHeight * 0.012, 
                  color: const Color(0xFF65B741)
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "= Approve", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)
                ),
                SizedBox(width: screenWidth * 0.08),
                Container(
                  width: screenWidth * 0.08, 
                  height: screenHeight * 0.012, 
                  color: const Color(0xFFE72929)
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "= Reject", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.025),

            // Pending / Confirmed Tab Bar එක
            Container(
              height: screenHeight * 0.055, // Screen එකේ උසින් 5.5% ක්
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isPendingTab = true),
                      child: Container(
                        margin: EdgeInsets.all(screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: isPendingTab ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Pending",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isPendingTab = false),
                      child: Container(
                        margin: EdgeInsets.all(screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: !isPendingTab ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Confirmed",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Table Headers
            Row(
              children: [
                Expanded(
                  flex: 3, 
                  child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038))
                ),
                Expanded(
                  flex: 3, 
                  child: Text("Specialization", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038), textAlign: TextAlign.center)
                ),
                Expanded(
                  flex: 2, 
                  child: Text("Stats", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038), textAlign: TextAlign.right)
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            const Divider(thickness: 1),

            // Firebase Data List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .where('status', isEqualTo: isPendingTab ? 'pending' : 'approved')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text("No doctors found.", style: TextStyle(fontSize: screenWidth * 0.04)),
                    );
                  }

                  final doctors = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      var doc = doctors[index];
                      String docId = doc.id;
                      String name = doc['Full-Name'] ?? 'Unknown';
                      String specialization = doc['Specialization'] ?? 'General';

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                        child: Row(
                          children: [
                            // Doctor Name
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Dr. $name",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: screenWidth * 0.032),
                                overflow: TextOverflow.ellipsis, // දිග වැඩිනම් ... ලෙස පෙන්වයි
                              ),
                            ),
                            // Specialization
                            Expanded(
                              flex: 3,
                              child: Text(
                                specialization,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Action Buttons
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: isPendingTab
                                    ? [
                                        // Approve Button
                                        GestureDetector(
                                          onTap: () => _updateDoctorStatus(docId, 'approved'),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.003),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF65B741),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Icon(Icons.check, color: Colors.white, size: screenWidth * 0.035),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.015),
                                        // Reject Button
                                        GestureDetector(
                                          onTap: () => _updateDoctorStatus(docId, 'rejected'),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.003),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE72929),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Icon(Icons.close, color: Colors.white, size: screenWidth * 0.035),
                                          ),
                                        ),
                                      ]
                                    : [
                                        Text(
                                          "Approved", 
                                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03)
                                        )
                                      ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar Placeholder
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        selectedFontSize: screenWidth * 0.03,
        unselectedFontSize: screenWidth * 0.03,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Doctors'),
        ],
      ),
    );
  }
}