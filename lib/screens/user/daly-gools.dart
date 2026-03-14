import 'package:flutter/material.dart';

class DailyGoalsPage extends StatelessWidget {
  final String mood;
  const DailyGoalsPage({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    // මූඩ් 5ට අදාළ දේවල් 5 බැගින්
    Map<String, List<String>> moodGoals = {
      "Happy": ["සතුට බෙදාගන්න", "ප්‍රියතම සිංදුවක් අහන්න", "පින්තූරයක් ගන්න", "කැමති කෑමක් කන්න", "යාළුවෙක්ට කතා කරන්න"],
      "Sad": ["ගැඹුරට හුස්ම ගන්න", "විනාඩි 10ක් ඇවිදින්න", "හොඳ නින්දක් ගන්න", "චිත්‍රයක් අඳින්න", "හිත නිවන සංගීතයක් අහන්න"],
      "Angry": ["වතුර වීදුරුවක් බොන්න", "විනාඩි 5ක් තනියම ඉන්න", "ව්‍යායාම කරන්න", "සන්සුන් සංගීතයක් අහන්න", "1 සිට 10 ට ගණන් කරන්න"],
      "Anxious": ["භාවනා කරන්න", "Screen time අඩු කරන්න", "රස්නයට තේ එකක් බොන්න", "ධනාත්මකව හිතන්න", "බය හිතෙන දේ ලියන්න"],
      "Neutral": ["පොතක් කියවන්න", "කාමරය අස් කරන්න", "අලුත් Plan එකක් හදන්න", "හවසට ඇවිදින්න යන්න", "හුස්ම ගැනීමේ ව්‍යායාම කරන්න"],
    };

    List<String> todayGoals = moodGoals[mood] ?? moodGoals["Neutral"]!;

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Daily Goals"), backgroundColor: const Color(0xFF5DB004)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("ඔබේ $mood මනෝභාවය අනුව අද දිනට නිර්දේශිත ක්‍රියාකාරකම්:",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: todayGoals.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: const Color(0xFF5DB004), child: Text("${index + 1}", style: const TextStyle(color: Colors.white))),
                      title: Text(todayGoals[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}