import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../doctor/doctor_dashboard.dart';
import '../../widgets/w-second.dart';

class DoctorLoginPage extends StatefulWidget {
  const DoctorLoginPage({super.key});

  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isObscured = true;
  bool _isLoading = false;

  Future<void> _doctorLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 1. මුලින්ම 'confirm-doctor' table එකේ ඉන්නවද කියලා බලමු (Approved නම් ඉන්නේ මෙතන)
      DocumentSnapshot confirmedDoc = await FirebaseFirestore.instance
          .collection('confirm-doctor')
          .doc(uid)
          .get();

      if (confirmedDoc.exists) {
        if (mounted) {
          String doctorName = confirmedDoc['Full-Name'] ?? 'Doctor';

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboardPage(
                doctorName: doctorName,
              ),
            ),
          );
        }
        return; // වැඩේ ඉවරයි
      }

      // 2. එතන නැත්නම් 'doctors' table එකේ (Pending/Rejected) ඉන්නවද බලමු
      DocumentSnapshot pendingDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .get();

      if (pendingDoc.exists) {
        String status = pendingDoc['status'] ?? 'pending';

        if (status == 'pending') {
          if (mounted) {
            String doctorName = pendingDoc['Full-Name'] ?? 'Doctor';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorPendingApprovalPage(doctorName: doctorName),
              ),
            );
          }
        } else if (status == 'rejected') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Your application was rejected. Please contact admin."),
                backgroundColor: Colors.red,
              ),
            );
          }
          await FirebaseAuth.instance.signOut();
        }
      } else {
        // කොහෙවත්ම නැත්නම්
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Doctor profile not found")),
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      String errorMsg = "Login failed";
      if (e.code == 'user-not-found') {
        errorMsg = "Doctor email not found";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Incorrect password";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Doctor Login",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.08),
            Center(
              child: Icon(
                Icons.medical_services_outlined,
                size: screenWidth * 0.2,
                color: const Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            Center(
              child: Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Text(
                "Login to your doctor account",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.08),
            Text("Email Address", style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w600)),
            SizedBox(height: screenHeight * 0.01),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter your email",
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Text("Password", style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w600)),
            SizedBox(height: screenHeight * 0.01),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _isObscured,
              decoration: InputDecoration(
                hintText: "Enter your password",
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : CustomButton(text: "Login", onPressed: _doctorLogin),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}

class DoctorPendingApprovalPage extends StatelessWidget {
  final String doctorName;
  const DoctorPendingApprovalPage({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
            Text("Dr. $doctorName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Your account is pending approval."),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            )
          ],
        ),
      ),
    );
  }
}