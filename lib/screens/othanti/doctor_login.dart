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
      // Firebase Authentication සහ نام
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Firestore එකෙන් Doctor Data එක ගැනීම
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(userCredential.user!.uid)
          .get();

      if (!doctorSnapshot.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Doctor profile not found")),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Doctor Status Check කිරීම
      String status = doctorSnapshot['status'] ?? 'pending';

      if (status == 'approved') {
        // Approved නම් Dashboard එකට යවමු
        if (mounted) {
          String doctorName = doctorSnapshot['Full-Name'] ?? 'Doctor';
          String doctorId = doctorSnapshot['Enter-doctor-id'] ?? '';

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(
                doctorName: doctorName,
                doctorId: doctorId,
                uid: userCredential.user!.uid,
              ),
            ),
          );
        }
      } else if (status == 'pending') {
        // Pending නම් දෙවැනි පිටුවට යවමු
        if (mounted) {
          String doctorName = doctorSnapshot['Full-Name'] ?? 'Doctor';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DoctorPendingApprovalPage(doctorName: doctorName),
            ),
          );
        }
      } else if (status == 'rejected') {
        // Rejected නම් error message පෙන්වමු
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Your application was rejected. Please contact admin.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Firebase logout
        await FirebaseAuth.instance.signOut();
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

            // Email Field
            Text(
              "Email Address",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                hintText: "Enter your email",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            SizedBox(height: screenHeight * 0.025),

            // Password Field
            Text(
              "Password",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _isObscured,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                hintText: "Enter your password",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black54,
                  ),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  )
                : CustomButton(text: "Login", onPressed: _doctorLogin),

            SizedBox(height: screenHeight * 0.03),
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

// Doctor පිටුවට යාමට පෙර අනුමතිය බලාපොරොත්තු වෙන පිටුව
class DoctorPendingApprovalPage extends StatelessWidget {
  final String doctorName;

  const DoctorPendingApprovalPage({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pending Approval",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_empty_rounded,
                size: 80,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 30),
              Text(
                "Hello Dr. $doctorName,",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "Your account is pending admin approval. Please wait for the admin to verify your credentials.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Back to Login",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
