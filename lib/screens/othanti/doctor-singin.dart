import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animated_calculator/widgets/w-second.dart';

class DoctorRegistrationPage extends StatefulWidget {
  const DoctorRegistrationPage({super.key});

  @override
  State<DoctorRegistrationPage> createState() => _DoctorRegistrationPageState();
}

class _DoctorRegistrationPageState extends State<DoctorRegistrationPage> {
  // Input fields control කරන්න controllers ටික
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _slmcController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Specialization list එක සහ තෝරාගන්නා අගය තියාගන්නා variable
  final List<String> _specializations = ['Cardiologist', 'Neurologist', 'Pediatrician', 'General Physician'];
  String? _selectedSpecialization;

  File? _image; // තෝරාගත් photo එක තියාගන්න
  bool _isUploading = false; // Upload වෙන වෙලාවට loading පෙන්වන්න

  // Gallery එකෙන් photo එකක් තෝරාගැනීමේ function එක
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Cloudinary එකට image එක upload කරලා එහි URL එක ලබාගැනීම
  Future<String> _uploadToCloudinary(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dsr08jyjr/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'mental-health'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      return jsonMap['secure_url']; // Cloudinary URL එක return කරයි
    } else {
      throw Exception("Cloudinary upload failed");
    }
  }

  // දත්ත register කිරීම සහ Firestore හි save කිරීමේ ප්‍රධාන function එක
  Future<void> _registerAndSaveData() async {
    // අත්‍යාවශ්‍ය field පිරී ඇත්දැයි බැලීම
    if (_idController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields!")),
      );
      return;
    }

    // Password දෙක සමාන දැයි පරීක්ෂා කිරීම
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Firebase Authentication හි account එක සෑදීම
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Auth එකෙන් ලැබෙන Unique UID එක ලබාගැනීම
      String uid = userCredential.user!.uid;
      String photoUrl = "";

      // 2. Photo එකක් තිබේ නම් එය Cloudinary වෙත යැවීම
      if (_image != null) {
        photoUrl = await _uploadToCloudinary(_image!);
      }

      // 3. Firestore හි 'doctors' collection එකේ දත්ත save කිරීම
      // මෙහිදී document ID එක ලෙස Auth UID එකම භාවිතා කරයි (Connect කිරීමට)
      await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
        'Enter-doctor-id': _idController.text.trim(),
        'Full-Name': _nameController.text.trim(),
        'Email-Address': _emailController.text.trim(),
        'Phone-Number': _phoneController.text.trim(),
        'Specialization': _selectedSpecialization ?? "",
        'SLMC': _slmcController.text.trim(),
        'Experience': _expController.text.trim(),
        'Photo': photoUrl,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // සාර්ථක නම් Success Page එකට යොමු කිරීම
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SuccessPage()));
      }
    } on FirebaseAuthException catch (e) {
      // Authentication errors handle කිරීම
      String errorMsg = "Registration failed";
      if (e.code == 'email-already-in-use') errorMsg = "Email already in use!";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen එකේ උස සහ පළල ලබාගැනීම (Responsiveness සඳහා)
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
        title: const Text("Doctor Registration", style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo එක තෝරාගැනීමේ UI එක
            GestureDetector(
              onTap: _pickImage,
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.18,
                        height: screenWidth * 0.18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                          image: _image != null
                              ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                              : null,
                        ),
                      ),
                      if (_image == null) const Icon(Icons.camera_alt_outlined, color: Colors.white),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  const Text("Upload Profile Photo", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03), // Screen size අනුව ඉඩ තැබීම
            const Divider(),
            SizedBox(height: screenHeight * 0.02),

            // TextField භාවිතා කර දත්ත ඇතුළත් කරන කොටස්
            _buildTextField(context, "Enter doctor id", controller: _idController),
            _buildTextField(context, "Full Name", controller: _nameController),
            _buildTextField(context, "Email Address", controller: _emailController),
            _buildTextField(context, "Phone Number", isNumber: true, controller: _phoneController),

            _buildLabel("Specialization"),
            // විශේෂඥතාව තෝරාගැනීමට Dropdown එක
            DropdownButtonFormField<String>(
              decoration: _inputDecoration(),
              hint: const Text('select specialization'),
              value: _selectedSpecialization,
              items: _specializations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSpecialization = val),
            ),

            SizedBox(height: screenHeight * 0.025),
            Row(
              children: [
                Expanded(child: _buildTextField(context, "SLMC", controller: _slmcController)),
                SizedBox(width: screenWidth * 0.04),
                Expanded(child: _buildTextField(context, "Experience (Y)", isNumber: true, controller: _expController)),
              ],
            ),

            // Password සහ Confirm Password ඇතුළත් කරන කොටස
            Row(
              children: [
                Expanded(child: _buildTextField(context, "Password", isPassword: true, controller: _passwordController)),
                SizedBox(width: screenWidth * 0.04),
                Expanded(child: _buildTextField(context, "Confirm", isPassword: true, controller: _confirmPasswordController)),
              ],
            ),

            SizedBox(height: screenHeight * 0.05),

            // Register Button එක හෝ Upload වන විට පෙන්වන Loader එක
            _isUploading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                : CustomButton(
              text: "Register As Doctor",
              onPressed: _registerAndSaveData,
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  // Label එකක් සෑදීමට උදවු වන function එක
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
  );

  // TextField වලට පොදු decoration එකක් ලබාදීම
  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
    filled: true,
    fillColor: Colors.grey[50],
  );

  // TextField එකක් සෑදීම පහසු කරන function එක (Screen height අනුව spacing සකසා ඇත)
  Widget _buildTextField(BuildContext context, String label, {bool isPassword = false, bool isNumber = false, TextEditingController? controller}) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDecoration(),
        ),
        // Screen height එකෙන් 2% ක ඉඩක් පහළින් තබයි
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }
}

// සාර්ථකව register වූ පසු පෙන්වන සරල Page එක
class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Registration Successful!")));
  }
}