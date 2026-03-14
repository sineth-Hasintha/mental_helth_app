import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // 1. Google Sign-In ලයිබ්‍රරි එක
import 'package:animated_calculator/widgets/w-second.dart';
import 'signup_page.dart';
import 'forgrt-password.dart';
import 'package:animated_calculator/screens/user/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  bool _rememberMe = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- පියවර 2: Google හරහා Login වන ප්‍රධාන Function එක ---
  Future<void> _signInWithGoogle() async {
    try {
      // Google එකේ Account තෝරන පේජ් එක පෙන්වනවා
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // යූසර් cancel කළොත් නිකන් ඉන්නවා

      // Auth විස්තර ලබාගන්නවා
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase එකට අවශ්‍ය Credential එක සාදාගන්නවා
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase වලට ලොගින් වෙනවා
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // සාර්ථක නම් Home Screen එකට යවනවා
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: userCredential.user?.displayName ?? "User"),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      // මොකක් හරි වැරැද්දක් වුණොත් පෙන්වනවා
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Error: $e")),
      );
    }
  }

  Future<void> _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: email.split('@')[0]),
          ),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "An error occurred";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF5DB004), width: 2),
      ),
    );
  }

  void _navigateTo(Widget targetPage) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fieldWidth = screenWidth * 0.88;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.05, top: screenHeight * 0.015),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            const Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Container(height: 3, width: 100, color: Colors.black, margin: const EdgeInsets.only(top: 1)),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _navigateTo(const SignupPage()),
                          child: const Text("Sign up", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Text("please enter your login details to sign in", style: TextStyle(color: Colors.black, fontSize: 14)),
                    SizedBox(height: screenHeight * 0.04),

                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("Email Address"),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Center(
                      child: SizedBox(
                        width: fieldWidth,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: _inputDecoration("Password").copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black),
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) => setState(() => _rememberMe = val!),
                            ),
                            const Text("Keep me log in", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _navigateTo(const ForgotPasswordScreen()),
                          child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    CustomButton(
                      text: "Log in",
                      onPressed: _loginUser,
                    ),

                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => _navigateTo(const SignupPage()),
                          child: const Text("Signup", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or continue with")),
                        Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // --- පියවර 3: Gmail Icon එක මෙතැනදී වෙනස් කළා ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _socialIconButton(context, 'assets/images/gmail.png', _signInWithGoogle), // Google Login එක call වෙනවා
                        _socialIconButton(context, 'assets/images/fb.png', () {}),
                        _socialIconButton(context, 'assets/images/apple.png', () {}),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- පියවර 4: IconButton එක පේජ් එකකට යනවා වෙනුවට ඕනෑම වැඩක් (Function එකක්) කළ හැකි ලෙස සකස් කළා ---
  Widget _socialIconButton(BuildContext context, String imagePath, VoidCallback onTapAction) {
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTapAction,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: sHeight * 0.08,
        width: sWidth * 0.18,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }
}