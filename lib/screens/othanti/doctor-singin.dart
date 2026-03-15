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
  // TextField පාලනය සඳහා Controllers (ID සහ City ඇතුළුව)
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _slmcController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(); // City සඳහා අලුත් Controller එක

  final List<String> _specializations = ['Cardiologist', 'Neurologist', 'Pediatrician', 'General Physician'];
  String? _selectedSpecialization;

  File? _image;
  bool _isUploading = false;

  // ගැලරියෙන් පින්තූරයක් තෝරාගැනීම
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Cloudinary වෙත පින්තූරය Upload කර URL එක ලබාගැනීම
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
      return jsonMap['secure_url'];
    } else {
      throw Exception("Cloudinary upload failed");
    }
  }

  // දත්ත ලියාපදිංචි කිරීමේ ප්‍රධාන Function එක
  Future<void> _registerAndSaveData() async {
    // අත්‍යාවශ්‍ය කොටස් පිරී ඇත්දැයි බැලීම (ID, Email, Password)
    if (_idController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields!")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Firebase Authentication හි ගිණුම සෑදීම
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Auth එකෙන් ලැබෙන Unique UID එක ලබාගැනීම
      String uid = userCredential.user!.uid;
      String photoUrl = "";

      // 2. පින්තූරයක් තිබේ නම් එය Cloudinary වෙත යැවීම
      if (_image != null) {
        photoUrl = await _uploadToCloudinary(_image!);
      }

      // 3. Firestore හි 'doctors' collection එකේ දත්ත save කිරීම
      // මෙහිදී document ID එක ලෙස Auth UID එකම භාවිතා කර ඇත
      await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
        'Doctor-ID': _idController.text.trim(), // Doctor ID එක
        'Full-Name': _nameController.text.trim(),
        'Email-Address': _emailController.text.trim(),
        'Phone-Number': _phoneController.text.trim(),
        'Specialization': _selectedSpecialization ?? "",
        'SLMC': _slmcController.text.trim(),
        'Experience': _expController.text.trim(),
        'City': _cityController.text.trim(), // City අගය ගබඩා කිරීම
        'Photo': photoUrl,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // සාර්ථක නම් Success Page එකට යොමු කිරීම
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SuccessPage()));
      }
    } on FirebaseAuthException catch (e) {
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
            SizedBox(height: screenHeight * 0.03),
            const Divider(),
            SizedBox(height: screenHeight * 0.02),

            // TextField භාවිතා කර දත්ත ඇතුළත් කරන කොටස් (ID නැවත එකතු කර ඇත)
            _buildTextField(context, "Doctor ID", controller: _idController),
            _buildTextField(context, "Full Name", controller: _nameController),
            _buildTextField(context, "Email Address", controller: _emailController),
            _buildTextField(context, "Phone Number", isNumber: true, controller: _phoneController),

            _buildLabel("Specialization"),
            // Dropdown එක
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

            // Password සහ City ඇතුළත් කරන Row එක
            Row(
              children: [
                Expanded(child: _buildTextField(context, "Password", isPassword: true, controller: _passwordController)),
                SizedBox(width: screenWidth * 0.04),
                // City සඳහා TextField එක
                Expanded(child: _buildTextField(context, "City", controller: _cityController)),
              ],
            ),

            SizedBox(height: screenHeight * 0.05),

            // Register Button එක හෝ Loading එක
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

  // Label එකක් සෑදීමේ Function එක
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
  );

  // TextField සඳහා පොදු Decoration එක
  InputDecoration _inputDecoration() => InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5)),
    filled: true,
    fillColor: Colors.grey[50],
  );

  // TextField සෑදීම පහසු කරන function එක
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
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }
}

// සාර්ථකව ලියාපදිංචි වූ පසු පෙන්වන Page එක
class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Registration Successful!")));
  }
}