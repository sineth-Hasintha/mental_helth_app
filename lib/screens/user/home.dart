import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mode-track.dart';
import 'daly-gools.dart';
import 'chat-with-ai-1.dart';
import 'docter-see.dart';
class HomeScreen extends StatelessWidget {
  final String? userName;

  const HomeScreen({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    // නම අරගන්න logic එක - නමක් නැති වුණොත් "Guest" ලෙස ගනී
    final String displayName = userName ?? "Guest";

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi $displayName,", // මෙතන දැන් Error එක එන්නේ නැහැ
              style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
            ),
            Text(
              "how are you feeling today?",
              style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.grey[700]
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: screenHeight * 0.025,
                crossAxisSpacing: screenWidth * 0.05,
                childAspectRatio: 0.85,
                children: [
                  _menuBtn(
                      context,
                      "Chat with ai",
                      "assets/images/ca.png",
                      const Color(0xFF39B539),
                      AIAssistantPage(userName: displayName), // මෙතනටත් ලස්සනට නම යනවා
                      screenWidth
                  ),

                  _menuBtn(context, "Mood Tracker", "assets/images/mt.png", const Color(0xFF91E491), const MoodTrackerPage(), screenWidth),

                  _menuBtn(context, "Doctor Consultation", "assets/images/dc.png", const Color(0xFFB4E68E), const DoctorListScreen(), screenWidth),

                  _dailyGoalsBtn(context, "Daily Goals", "assets/images/dg.png", const Color(0xFF5D8B2C), screenWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- පහළ තියෙන Functions ඔයාගේ විදිහටම තියෙනවා ---

  Widget _dailyGoalsBtn(BuildContext context, String title, String imgPath, Color bgColor, double screenWidth) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        String lastMood = prefs.getString('last_mood') ?? "Neutral";

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyGoalsPage(mood: lastMood)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.07),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imgPath, width: screenWidth * 0.15, height: screenWidth * 0.15, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    color: Colors.black.withOpacity(0.8)
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuBtn(BuildContext context, String title, String imgPath, Color bgColor, Widget nextPage, double screenWidth) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage)),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.07),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imgPath, width: screenWidth * 0.15, height: screenWidth * 0.15, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    color: Colors.black.withOpacity(0.8)
                )
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorDummy extends StatelessWidget {
  const DoctorDummy({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(), body: const Center(child: Text("Doctor Page")));
}
