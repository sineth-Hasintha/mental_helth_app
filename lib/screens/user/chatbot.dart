import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotPage extends StatefulWidget {
  final String userName;

  const ChatBotPage({super.key, required this.userName});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // --- API Key එක (OpenAI Dashboard එකෙන් ගත්තු විදිහට) ---
  final String _apiKey = "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";

  Future<void> _getResponse(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": "You are a mental health assistant. The user's name is ${widget.userName}. Speak kindly in Sinhala and English."
            },
            ..._messages
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": data['choices'][0]['message']['content'].toString().trim()
          });
        });
      } else {
        // සල්ලි නැතිනම් හෝ වෙනත් Error එකක් නම් මෙතනින් බලාගන්න පුළුවන්
        debugPrint("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions ලබා ගැනීම (Responsiveness සඳහා)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Section (Responsive) ---
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.01
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Hi ${widget.userName}, AI Chat",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0B3A02),
                        ),
                      ),
                    ),
                  ),
                  // IconButton එකට සමාන ඉඩක් තැබීම සඳහා screenWidth පාවිච්චි කිරීම
                  SizedBox(width: screenWidth * 0.12),
                ],
              ),
            ),

            // --- Chat Messages Section ---
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isUser = _messages[index]['role'] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(screenWidth * 0.035),
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.75, // උපරිම පළල screen එකෙන් 75% කි
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(15),
                          topRight: const Radius.circular(15),
                          bottomLeft: Radius.circular(isUser ? 15 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 15),
                        ),
                      ),
                      child: Text(
                        _messages[index]['content']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              const LinearProgressIndicator(color: Color(0xFF0EA616)),

            // --- Input Section (Responsive) ---
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(fontSize: screenWidth * 0.04),
                        decoration: const InputDecoration(
                          hintText: "ඔබේ ගැටලුව පවසන්න...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  CircleAvatar(
                    radius: screenWidth * 0.06,
                    backgroundColor: const Color(0xFF0EA616),
                    child: IconButton(
                      icon: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: screenWidth * 0.05
                      ),
                      onPressed: () => _getResponse(_controller.text),
                    ),
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