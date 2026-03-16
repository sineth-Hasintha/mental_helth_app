import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'after-see.doctor.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  // සෙවුම් පාලකය (Search Controller)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Screen එකේ ප්‍රමාණයන් ලබා ගැනීම (Responsiveness සඳහා)
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // පසුබිම් අලංකරණ රවුම
          Positioned(
            right: -screenWidth * 0.17,
            top: screenHeight * 0.2,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: const BoxDecoration(
                color: Color(0xFF5DB004),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: screenWidth * 0.6,
            top: screenHeight * 0.6,
            child: Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: const BoxDecoration(
                color: Color(0xFF5DB004),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back Button එක
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.03, top: screenHeight * 0.01),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: screenWidth * 0.06),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // සර්ච් බාර් එක (Responsive)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.01
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                    ),
                    child: TextField(
                      controller: _searchController,
                      // නම, විශේෂඥතාවය හෝ නගරය අනුව Filter කිරීම
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Search Name, Spec or City",
                        prefixIcon: Icon(Icons.search, size: screenWidth * 0.06),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Firestore ලැයිස්තුව
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('confirm-doctor').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text("Error fetching data"));
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const Center(child: CircularProgressIndicator());

                      // පෙරා ගත් (Filtered) දත්ත ලැයිස්තුව
                      var filteredList = snapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String name = (data['Full-Name'] ?? "").toString().toLowerCase();
                        String spec = (data['Specialization'] ?? "").toString().toLowerCase();
                        String city = (data['City'] ?? "").toString().toLowerCase();

                        return name.contains(_searchQuery) ||
                            spec.contains(_searchQuery) ||
                            city.contains(_searchQuery);
                      }).toList();

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          // filteredList[index] එක DocumentSnapshot එකක් ලෙස යවනවා
                          return _buildDoctorCard(context, filteredList[index], screenWidth, screenHeight);
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

  // ඩොක්ටර් කාඩ් එක (Responsive)
  Widget _buildDoctorCard(BuildContext context, DocumentSnapshot doc, double sWidth, double sHeight) {
    // Firestore දත්ත ලබා ගැනීම
    var data = doc.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        // මෙහිදී 'Doctor-ID' ඇතුළු සියලුම දත්ත 'data' Map එක හරහා ඊළඟ පිටුවට යැවේ.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorDetailsPage(),
            settings: RouteSettings(arguments: data),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: sHeight * 0.02),
        padding: EdgeInsets.all(sWidth * 0.035),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(sWidth * 0.05),
        ),
        child: Row(
          children: [
            // Profile Photo
            CircleAvatar(
              radius: sWidth * 0.09,
              backgroundImage: (data['Photo'] != null && data['Photo'] != "g")
                  ? NetworkImage(data['Photo'])
                  : const NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(width: sWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dr. ${data['Full-Name'] ?? ''}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sWidth * 0.045,
                        color: const Color(0xFF0070C0)
                    ),
                  ),
                  Text(
                      "${data['Specialization'] ?? ''}",
                      style: TextStyle(fontSize: sWidth * 0.035, color: Colors.black54)
                  ),
                  // නගරය පෙන්වීම
                  Text(
                      "City: ${data['City'] ?? 'N/A'}",
                      style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: sWidth * 0.03
                      )
                  ),
                  // සටහන: data['Doctor-ID'] මෙහි UI එකේ පෙන්වන්නේ නැත, නමුත් එය 'arguments' හරහා යැවේ.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}