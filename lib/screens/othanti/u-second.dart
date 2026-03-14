import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Firebase Auth එක ඇඩ් කළා
import 'package:google_sign_in/google_sign_in.dart'; // 2. Google Sign-in එක ඇඩ් කළා
import 'login_page.dart';
import 'package:animated_calculator/screens/user/home.dart';
class LoginSelectPage extends StatelessWidget {
  const LoginSelectPage({super.key});

  // --- 3. Google Sign-in වැඩේ කරන Function එක ---
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      print("Google Login Success!");
      // Login වුණාට පස්සේ ඔයාට ඕන නම් මෙතනින් Home එකට යවන්න පුළුවන්
    } catch (e) {
      print("Google Login Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Image.asset(
                    'assets/images/fist.png',
                    height: screenHeight * 0.2,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.psychology, size: screenHeight * 0.15, color: const Color(0xFF66B000)),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                const Text(
                  "Welcome to Mindspace",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.015),
                const Text(
                  "create your account to get started in your\nhealth & happiness journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: screenHeight * 0.04),

                // --- 4. Gmail Button (මෙතන isGoogle: true කියලා දුන්නා) ---
                _socialButton(
                    context,
                    "Continue with Gmail",
                    'assets/images/gmail.png',
                    null, // dummy page එකක් ඕනේ නැහැ Google වලට
                    isGoogle: true
                ),

                SizedBox(height: screenHeight * 0.018),

                _socialButton(
                    context,
                    "Continue with Facebook",
                    'assets/images/fb.png',
                    const FBDummyPage()
                ),

                SizedBox(height: screenHeight * 0.018),

                _socialButton(
                    context,
                    "Continue with Email",
                    'assets/images/email.png',
                    const LoginPage()
                ),

                SizedBox(height: screenHeight * 0.03),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.05),

                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Fast Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/fg.png',
                          height: screenHeight *0.03 ,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.bolt, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 5. Social Button Helper එකේ onPressed එක වෙනස් කළා ---
  Widget _socialButton(BuildContext context, String text, String imagePath, Widget? targetPage, {bool isGoogle = false}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          if (isGoogle) {
            signInWithGoogle(context); // Google එකෙන් ලොග් වෙනවා
          } else if (targetPage != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height:45,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ඔයා ඉල්ලපු ඉතුරු Dummy Pages ටික මෙන්න ---

class FBDummyPage extends StatelessWidget {
  const FBDummyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Facebook")), body: const Center(child: Text("Facebook Dummy Page")));
}

class EmailDummyPage extends StatelessWidget {
  const EmailDummyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Email")), body: const Center(child: Text("Email Dummy Page")));
}

class FastLoginDummyPage extends StatelessWidget {
  const FastLoginDummyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Fast Login")), body: const Center(child: Text("Fast Login Dummy Page")));
}