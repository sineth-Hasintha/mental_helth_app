import 'package:flutter/material.dart';
import '../admin/Admin_Dashboard.dart';
import '../../widgets/w-second.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  bool _isObscured = true;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Focus nodes එකතු කළා keyboard එක force කරන්න
  final FocusNode _idFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  @override
  void dispose() {
    _idFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // මේක අනිවාර්යයි
      body: SafeArea(
        child: Column(
          children: [
            // --- Fixed Header (Back Button) ---
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.01,
                  top: screenHeight * 0.01,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
              ),
            ),

            // --- Scrollable Body ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Text(
                      'Please enter your login details to sign in',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    // ID Input Field
                    TextField(
                      controller: _idController,
                      focusNode: _idFocus,
                      autofocus: false, // ඉබේම එන එක නතර කරලා අපි ගමු
                      onTap: () {
                        FocusScope.of(context).requestFocus(_idFocus);
                      },
                      decoration: InputDecoration(
                        labelText: 'Admin ID',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Password Input Field
                    TextField(
                      controller: _passwordController,
                      focusNode: _passFocus,
                      obscureText: _isObscured,
                      onTap: () {
                        FocusScope.of(context).requestFocus(_passFocus);
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _isObscured = !_isObscured),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.06),

                    // Login Button
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.84,
                        child: CustomButton1(
                          title: "Log in",
                          onPressed: () {
                            if (_idController.text == "admin" &&
                                _passwordController.text == "1234") {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminDashboardPage(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
