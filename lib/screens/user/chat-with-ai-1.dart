import 'package:flutter/material.dart';
// මම කලින් දීපු ChatBotPage එක තියෙන file එක මෙතන import කරන්න
import 'chatbot.dart';

class AIAssistantPage extends StatelessWidget {
  // 1. මේ Variable එක අනිවාර්යයෙන්ම මෙතන තියෙන්න ඕනේ
  final String userName;

  // 2. Constructor එකට 'required this.userName' ඇතුළත් කළා
  const AIAssistantPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Your AI Assistant',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B3A02),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Using this software, you can ask your questions and receive articles using artificial intelligence assistant.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/chat.png',
                    width: screenWidth * 0.85,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: () {
                    // 3. මෙතනින් තමයි ඇත්තම Chat Bot එකට නම අරන් යන්නේ
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatBotPage(userName: userName),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA616),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}