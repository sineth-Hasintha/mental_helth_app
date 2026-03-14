import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase library eka
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore check karanna meka oni
import 'forgrt-password.dart';
import 'package:animated_calculator/widgets/w-second.dart';// Forgot password screen eka import kireema

class dlogin extends StatefulWidget {
  const dlogin({super.key});

  @override
  State<dlogin> createState() => _dloginState();
}

class _dloginState extends State<dlogin> {
  // Input fields control karana controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false; // Password penna/wahanna variable ekak
  bool _keepMeLoggedIn = true; // Checkbox state eka

  // --- Firebase Login Function එක ---
  Future<void> _handleLogin() async {
    // 1. Email saha Password empty da kiyala check kireema
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      // 2. Firebase Authentication check kireema
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Auth success unama, e user ge UID eka use karala Firestore eke 'doctors' collection eke innawada balanawa
      // UID eka doc ID eka widiyata check kireema (Registration ekedi UID eka doc ID kale meka nisa)
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userCredential.user!.uid)
          .get();

      if (doctorDoc.exists) {
        // Doctor kenek nam witharak Home yanawa
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SuccessPage()),
          );
        }
      } else {
        // Doctor kenek nethnam logout karala error ekak pennanawa
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Access Denied. You are not registered as a doctor."), backgroundColor: Colors.orange),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Firebase errors (wrong password wage dewal) handle kireema
      String message = "Login failed!";
      if (e.code == 'user-not-found') message = "User kenek natha.";
      else if (e.code == 'wrong-password') message = "Password eka waradi.";

      // User ta error message ekak pennanna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen eke size eka gannawa hama display ekakatama set wenna (Responsiveness)
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      // 1. AppBar එක නිසා back button එක හැමවෙලේම උඩම stable වෙනවා (Scroll kalata thawa harennne na)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: screenWidth * 0.15, // Padding ekata ida hadanna leadingWidth eka wadi kala
        leading: Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.00, // Wam paththe padding
            right: screenWidth * 0.00, // Dakunu paththe padding
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: screenWidth * 0.07, // Icon size ekath responsive
            ),
          ),
        ),
      ),
      // 2. Keyboard eka awama scroll wenna SingleChildScrollView damma
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), // Side padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.01),
                const Text("Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: screenHeight * 0.02),
                const Text("please enter your login details to sign in", style: TextStyle(color: Colors.grey, fontSize: 16)),

                SizedBox(height: screenHeight * 0.02),

                // Email TextField
                _buildTextField(context, controller: _emailController, hintText: "email", isPassword: false),

                SizedBox(height: screenHeight * 0.02),

                // Password TextField
                _buildTextField(
                  context,
                  controller: _passwordController,
                  hintText: "Password",
                  isPassword: true,
                  isObscured: !_isPasswordVisible,
                  onSuffixIconTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),

                SizedBox(height: screenHeight * 0.015),

                // Checkbox saha Forgot Password Row eka
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _keepMeLoggedIn,
                          onChanged: (val) => setState(() => _keepMeLoggedIn = val!),
                        ),
                        const Text("Keep me log in"),
                      ],
                    ),
                    // Forgot Password Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                      },
                      child: const Text("Forgot Password?", style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                // Content eka scroll karanna ida dena SizedBox ekak (Spacer eka wenuwata)
                SizedBox(height: screenHeight * 0.09),

                // CustomButton widget eka call kireema
                CustomButton(
                  text: "Log in",
                  onPressed: _handleLogin, // Login trigger wenawa
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable TextField (Code eka piliwalata thiyaganna) ---
  Widget _buildTextField(BuildContext context, {required TextEditingController controller, required String hintText, required bool isPassword, bool isObscured = false, VoidCallback? onSuffixIconTap}) {
    double screenHeight = MediaQuery.of(context).size.height;
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: isPassword ? IconButton(icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility), onPressed: onSuffixIconTap) : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: screenHeight * 0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

// ---------------------------------------------------------
// CustomButton Widget (Responsive design ekath ekka)
// ---------------------------------------------------------

// ---------------------------------------------------------
// Success Page (Temporarily)
// ---------------------------------------------------------
class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Login Successful!")));
  }
}