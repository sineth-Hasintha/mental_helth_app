import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:animated_calculator/widgets/w-second.dart';
import 'login_page.dart';
import 'package:animated_calculator/screens/user/home.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // --- TextField වල තියෙන දත්ත ලබාගන්නා Controllers ---
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Google හරහා Login වීමේ Function එක ---
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Firebase එකට Google දත්ත ලබාදී Login වීම
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        if (mounted) {
          // සාර්ථක නම් Home Screen එකට යනවා
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: googleUser.displayName ?? "User")),
          );
        }
      }
    } catch (e) {
      // Error එකක් ආවොත් පෙන්වනවා
      _showSnackBar("Google Sign-In Failed: $e", Colors.red);
    }
  }

  // --- සාමාන්‍ය Email/Password Signup Function එක ---
  Future<void> _signUp() async {
    try {
      // Inputs හිස්ද කියලා මූලිකවම Check කරනවා
      if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        _showSnackBar("Please fill all details", Colors.orange);
        return;
      }

      // 1. Firebase Auth එකේ අලුත් Account එකක් හදනවා
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Account එක හැදුනාම, ඉතිරි දත්ත Firestore Database එකේ Save කරනවා
      // (පින්තූර upload කරන එක අයින් කර ඇති නිසා photo field එක මෙතන නැත)
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'first-name': _firstNameController.text.trim(),
        'city': _cityController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
      });

      if (mounted) {
        // ඔක්කොම හරි නම් Home Screen එකට User ව යවනවා
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: _firstNameController.text.trim()))
        );
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.red);
    }
  }

  // Error හෝ Success පණිවිඩ පෙන්වීමට SnackBar එකක්
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // Phone එකේ screen එකේ උස සහ පළල අනුපාත ලබා ගැනීම (Responsive කිරීමට)
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ආපසු යාමට Back Button එක
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.02, top: screenHeight * 0.01),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: screenWidth * 0.06),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),

                    // Login සහ Signup අතර මාරු වීමට ඇති Tabs
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                          child: Text("Login", style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Text("Sign up", style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, color: Colors.black)),
                            Container(
                                height: 3,
                                width: screenWidth * 0.2,
                                color: Colors.black,
                                margin: const EdgeInsets.only(top: 5)
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),
                    Text("Please enter your details to sign up", style: TextStyle(color: Colors.black54, fontSize: screenWidth * 0.035)),

                    // මීට කලින් මෙතැන තිබුණු Camera Icon එක සහ Photo Picker එක ඉවත් කරන ලදී
                    SizedBox(height: screenHeight * 0.04),

                    // Input Fields: screenWidth එක අනුව ප්‍රමාණය වෙනස් වේ
                    _responsiveTextField("First Name", _firstNameController, screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    _responsiveTextField("City", _cityController, screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    _responsiveTextField("Age", _ageController, screenWidth, isNumber: true),
                    SizedBox(height: screenHeight * 0.015),
                    _responsiveTextField("Email Address", _emailController, screenWidth),
                    SizedBox(height: screenHeight * 0.015),
                    _responsiveTextField("Password", _passwordController, screenWidth, isPassword: true),

                    SizedBox(height: screenHeight * 0.05),

                    // Signup Button එක (CustomWidget එකක් ලෙස පවතී)
                    CustomButton(
                      text: "Sign Up",
                      onPressed: _signUp,
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // මැද තියෙන Divider එක
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or continue with", style: TextStyle(color: Colors.grey))),
                        Expanded(child: Divider()),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Social Login Buttons: උස සහ පළල screen size එක අනුව auto හැදේ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _socialIconButton('assets/images/gmail.png', _signInWithGoogle, screenWidth, screenHeight),
                        _socialIconButton('assets/images/fb.png', () {}, screenWidth, screenHeight),
                        _socialIconButton('assets/images/apple.png', () {}, screenWidth, screenHeight),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TextField Responsive Widget එක ---
  Widget _responsiveTextField(String hint, TextEditingController controller, double sw, {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: sw * 0.035),
        contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF5DB004), width: 2)),
      ),
    );
  }

  // --- Social Icons Responsive Widget එක ---
  Widget _socialIconButton(String imagePath, VoidCallback onTap, double sw, double sh) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(sw * 0.03),
        height: sh * 0.075, // Screen උසින් 7.5% ක්
        width: sw * 0.22,   // Screen පළලින් 22% ක්
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
        ),
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }
}