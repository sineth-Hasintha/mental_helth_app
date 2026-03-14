import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  // සර්ච් බාර් එක පාලනය කරන Controller එක
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // 1. Responsive Design: ඕනෑම screen size එකකට ගැලපෙන ලෙස පළල සහ උස ලබාගැනීම
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // UI එකේ පසුබිම් අලංකරණ රවුම (Screen size එකට සාපේක්ෂව)
          Positioned(
            right: -screenWidth * 0.12,
            top: screenHeight * 0.2,
            child: Container(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              decoration: const BoxDecoration(
                  color: Color(0xFF5DB004),
                  shape: BoxShape.circle
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // බැක් බටන් එක (Back Button)
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.03, top: screenHeight * 0.01),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: screenWidth * 0.06),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // සර්ච් බාර් එක (Search Bar)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.01),
                  child: Container(
                    height: screenHeight * 0.07,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                    ),
                    child: TextField(
                      controller: _searchController,
                      // යූසර් ටයිප් කරන දේ අනුව List එක Filter කිරීම
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Find a doctor",
                        hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                        prefixIcon: Icon(Icons.search, color: Colors.black, size: screenWidth * 0.06),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Firestore දත්ත පෙන්වන කොටස
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text("Error fetching data"));
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                      // 2. Safe Filtering Logic: Field එක නැති වුණත් Crash නොවී පෙරා ගැනීම
                      var filteredDoctors = snapshot.data!.docs.where((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                        // FIX: 'Full-Name' සහ 'Specialization' field තිබේදැයි පරීක්ෂා කිරීම (Bad State Error එක වැළැක්වීමට)
                        String name = (data.containsKey('Full-Name') ? data['Full-Name'] : "").toString().toLowerCase();
                        String specialization = (data.containsKey('Specialization') ? data['Specialization'] : "").toString().toLowerCase();

                        return name.contains(_searchQuery) || specialization.contains(_searchQuery);
                      }).toList();

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          var doc = filteredDoctors[index];
                          return _buildDoctorCard(context, doc, screenWidth, screenHeight);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ඩොක්ටර් කාඩ් එක නිර්මාණය කරන Function එක
  Widget _buildDoctorCard(BuildContext context, DocumentSnapshot doc, double sWidth, double sHeight) {
    Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        // 3. Navigation: සියලුම Row Details ඊළඟ පේජ් එකට රැගෙන යාම
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorDetailsPage(),
            settings: RouteSettings(arguments: doctorData),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: sHeight * 0.02),
        padding: EdgeInsets.all(sWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(sWidth * 0.05),
        ),
        child: Row(
          children: [
            // 4. Image Logic: Photo එකක් නැතිනම් Default රූපයක් පෙන්වීම
            CircleAvatar(
              radius: sWidth * 0.1,
              backgroundColor: Colors.white,
              backgroundImage: (doctorData.containsKey('Photo') && doctorData['Photo'] != "")
                  ? NetworkImage(doctorData['Photo'])
                  : const NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(width: sWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ඩොක්ටර්ගේ නම පෙන්වීම
                  Text(
                    "Dr. ${doctorData['Full-Name'] ?? 'Unknown'}",
                    style: TextStyle(
                        fontSize: sWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0070C0)
                    ),
                  ),
                  SizedBox(height: sHeight * 0.005),
                  // විශේෂඥතාව (Specialization) පෙන්වීම
                  Text(
                      "${doctorData['Specialization'] ?? 'Consultant'}",
                      style: TextStyle(fontSize: sWidth * 0.035, color: Colors.black54)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// දත්ත ලැබෙන පේජ් එක (Doctor Details Page)
// ---------------------------------------------------------
class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // කලින් පේජ් එකෙන් එවපු මුළු data map එක මෙතනදී ලබාගන්නවා
    final Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final double sWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dr. ${data['Full-Name'] ?? 'Details'}"),
        backgroundColor: const Color(0xFF5DB004),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // පින්තූරය ස්ක්‍රීන් එකට ගැලපෙන සේ පෙන්වීම
            (data.containsKey('Photo') && data['Photo'] != "")
                ? Image.network(data['Photo'], width: sWidth, height: sWidth * 0.8, fit: BoxFit.cover)
                : Container(height: sWidth * 0.8, color: Colors.grey, child: const Icon(Icons.person, size: 100)),

            Padding(
              padding: EdgeInsets.all(sWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dr. ${data['Full-Name'] ?? 'Name not available'}",
                      style: TextStyle(fontSize: sWidth * 0.06, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text("Specialization: ${data['Specialization'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("Experience: ${data['Experience'] ?? '0'} Years", style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text("Email: ${data['Email-Address'] ?? 'N/A'}", style: const TextStyle(fontSize: 18, color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}