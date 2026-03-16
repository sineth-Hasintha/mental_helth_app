import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDoctorApprovalPage extends StatefulWidget {
  const AdminDoctorApprovalPage({super.key});

  @override
  State<AdminDoctorApprovalPage> createState() => _AdminDoctorApprovalPageState();
}

class _AdminDoctorApprovalPageState extends State<AdminDoctorApprovalPage> {
  bool isPendingTab = true;

  // Doctor ව Approve හෝ Reject කිරීමේ function එක
  Future<void> _updateDoctorStatus(String docId, String newStatus) async {
    try {
      // 1. doctors collection එකෙන් දත්ත ලබා ගැනීම
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> doctorData = docSnapshot.data() as Map<String, dynamic>;

        if (newStatus == 'approved') {
          // 2. confirm-doctor collection එකට දත්ත copy කිරීම
          doctorData['status'] = 'approved';

          await FirebaseFirestore.instance
              .collection('confirm-doctor')
              .doc(docId)
              .set(doctorData);

          // 3. doctors collection එකෙන් දත්ත ඉවත් කිරීම
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(docId)
              .delete();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Doctor moved to Confirmed Table!")),
            );
            // Tab එක මාරු කිරීම
            setState(() => isPendingTab = false);
          }
        } else {
          // Reject කළොත් status එක පමණක් update කිරීම
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(docId)
              .update({'status': 'rejected'});

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Doctor status updated to Rejected!")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
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
          children: [
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: screenWidth * 0.08, height: screenHeight * 0.012, color: const Color(0xFF65B741)),
                SizedBox(width: screenWidth * 0.02),
                Text("= Approve", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)),
                SizedBox(width: screenWidth * 0.08),
                Container(width: screenWidth * 0.08, height: screenHeight * 0.012, color: const Color(0xFFE72929)),
                SizedBox(width: screenWidth * 0.02),
                Text("= Reject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)),
              ],
            ),
            SizedBox(height: screenHeight * 0.025),

            // Tab Bar
            Container(
              height: screenHeight * 0.055,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  _buildTabItem("Pending", true, screenWidth),
                  _buildTabItem("Confirmed", false, screenWidth),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Headers
            Row(
              children: [
                Expanded(flex: 3, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038))),
                Expanded(flex: 3, child: Text("Specialization", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text("Stats", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038), textAlign: TextAlign.right)),
              ],
            ),
            const Divider(thickness: 1),

            // Firestore List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // මෙන්න මෙතනදී tab එක අනුව collection එක මාරු වෙනවා
                stream: FirebaseFirestore.instance
                    .collection(isPendingTab ? 'doctors' : 'confirm-doctor')
                    .where('status', isEqualTo: isPendingTab ? 'pending' : 'approved')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No doctors found.", style: TextStyle(fontSize: screenWidth * 0.04)));
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
                            Expanded(flex: 3, child: Text("Dr. $name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: screenWidth * 0.032), overflow: TextOverflow.ellipsis)),
                            Expanded(flex: 3, child: Text(specialization, textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: isPendingTab
                                    ? [
                                  _buildActionButton(Icons.check, const Color(0xFF65B741), () => _updateDoctorStatus(docId, 'approved'), screenWidth, screenHeight),
                                  SizedBox(width: screenWidth * 0.015),
                                  _buildActionButton(Icons.close, const Color(0xFFE72929), () => _updateDoctorStatus(docId, 'rejected'), screenWidth, screenHeight),
                                ]
                                    : [
                                  Text("Approved", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03))
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Doctors'),
        ],
      ),
    );
  }

  // Helper Widgets (Code එක කෙටි කිරීමට)
  Widget _buildTabItem(String title, bool isPending, double screenWidth) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isPendingTab = isPending),
        child: Container(
          margin: EdgeInsets.all(screenWidth * 0.01),
          decoration: BoxDecoration(
            color: isPendingTab == isPending ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenHeight * 0.003),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: Colors.white, size: screenWidth * 0.035),
      ),
    );
  }
}