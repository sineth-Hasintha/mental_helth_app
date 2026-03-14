import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// 1. මේ Import එක අනිවාර්යයෙන්ම එකතු කරන්න
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_calculator/widgets/w-second.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool get _isFormValid =>
      _nameController.text.isNotEmpty && _isValidEmail(_emailController.text);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leadingWidth: screenWidth * 0.1,
        leading: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.03,
            top: screenHeight * 0.02,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: screenWidth * 0.06),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Forgot password",
                style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                "Please enter your identity name and email",
                style: TextStyle(color: Colors.black54),
              ),
              SizedBox(height: screenHeight * 0.04),

              const Text("Your name", style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: screenHeight * 0.01),
              _customInputBox(_nameController, "Enter your name", false),

              SizedBox(height: screenHeight * 0.03),

              const Text("Your Email", style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: screenHeight * 0.01),
              _customInputBox(_emailController, "Enter your email", true),

              SizedBox(height: screenHeight * 0.08),

              // Reset Button
              CustomButton(
                text: "Reset Password",
                // 2. මෙතන onPressed එක async ලෙස වෙනස් කර Reset Link එක යවන code එක ඇතුළත් කර ඇත
                onPressed: () async {
                  if (_nameController.text.isEmpty) {
                    _showError(context, "Please enter your name!");
                  } else if (!_isValidEmail(_emailController.text)) {
                    _showError(context, "Please enter a valid email address (e.g. name@gmail.com)");
                  } else {
                    try {
                      // Firebase එක හරහා Reset Link එක ඊමේල් එකට යවන ප්‍රධාන පේළිය
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: _emailController.text.trim(),
                      );

                      // සාර්ථකව Link එක ගියාම User ට දැනුම් දෙන Dialog එක
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Success"),
                            content: const Text("Reset link sent to your email! Please check your inbox."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Dialog එක වහනවා
                                  Navigator.pop(context); // ආපහු Login Screen එකට යනවා
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      // මොකක් හරි වැරැද්දක් වුණොත් (උදා: Email එක නැතිනම්) පෙන්වන error එක
                      _showError(context, e.message ?? "An error occurred");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _customInputBox(TextEditingController controller, String hint, bool isEmail) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}