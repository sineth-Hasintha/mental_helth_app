import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _concernController = TextEditingController();

  DateTime? _selectedDate;
  String _formattedDateText = "Select Date";
  List<String> _availableSlots = [];
  String? _selectedTimeSlot;
  String _selectedConsultationType = "Message";

  bool _isLoadingSlots = false;
  String? _doctorName;
  String? _doctorId;
  String? _cloudinaryImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _doctorName = args['docName'];
      // ID එක String එකක් ලෙස සහ Spaces රහිතව ලබා ගනී
      _doctorId = args['docId']?.toString().trim();
      _cloudinaryImageUrl = args['Photo'];
    }
  }

  // 1. දින දර්ශනය පෙන්වීම සහ තෝරාගන්නා දවස අනුව Schedule එක Load කිරීම
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formattedDateText = DateFormat('dd MMM yyyy').format(picked);
        _selectedTimeSlot = null; // දවස වෙනස් කළ විට වෙලාව Reset කරයි
      });
      // තෝරාගත් දිනයට අදාළ වෙලාවන් Load කිරීම
      _loadTimeSlotsForSelectedDate(picked);
    }
  }

  // 2. දත්ත පද්ධතියෙන් (Firestore) දවසට අදාළ වෙලාවන් ලබා ගැනීම
  Future<void> _loadTimeSlotsForSelectedDate(DateTime date) async {
    if (_doctorId == null) return;

    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
    });

    try {
      // දින දර්ශනයෙන් ලැබෙන දවසේ නම (උදා: Monday)
      String dayName = DateFormat('EEEE').format(date);

      // doctor-sha collection එකේ Doctor-ID field එක සසඳා බැලීම
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctor-sha')
          .where('Doctor-ID', isEqualTo: _doctorId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

        // Firestore හි එම දවසේ නමින් (Monday, Sunday...) field එකක් තිබේදැයි බැලීම
        if (data != null && data.containsKey(dayName)) {
          setState(() {
            _availableSlots = List<String>.from(data[dayName]);
          });
        } else {
          // එම දවසේ දත්ත නොමැති නම්
          setState(() => _availableSlots = []);
        }
      } else {
        // ID එක mismatch වූ විට
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Doctor ID not found in schedule!"))
          );
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  // 3. Appointment එක Pending-Approvals වෙත සේව් කිරීම
  Future<void> _saveAppointmentToPendingApprovals() async {
    if (_selectedDate == null || _selectedTimeSlot == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields!"), backgroundColor: Colors.redAccent)
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Pending-Approvals').add({
        'doctorName': _doctorName,
        'doctorId': _doctorId,
        'doctorImage': _cloudinaryImageUrl,
        'userName': _nameController.text,
        'appointmentDate': _formattedDateText,
        'appointmentTime': _selectedTimeSlot,
        'consultationType': _selectedConsultationType,
        'description': _concernController.text,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking Successful!"), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sHeight = MediaQuery.of(context).size.height;
    final double sWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            right: -sWidth * 0.15, top: sHeight * 0.15,
            child: Container(width: sWidth * 0.5, height: sWidth * 0.5, decoration: BoxDecoration(color: Colors.green.withOpacity(0.6), shape: BoxShape.circle)),
          ),
          Positioned(
            left: -sWidth * 0.25, bottom: -sHeight * 0.1,
            child: Container(width: sWidth * 0.6, height: sWidth * 0.6, decoration: BoxDecoration(color: Colors.green.withOpacity(0.6), shape: BoxShape.circle)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: sWidth * 0.05, vertical: sHeight * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.arrow_back_ios, size: sWidth * 0.06), onPressed: () => Navigator.pop(context)),
                      SizedBox(width: sWidth * 0.1),
                      Text("Book an appointment", style: TextStyle(fontSize: sWidth * 0.055, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: sHeight * 0.015),

                  // Doctor Info Card
                  Container(
                    width: sWidth,
                    padding: EdgeInsets.all(sWidth * 0.04),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: sWidth * 0.08,
                          backgroundColor: Colors.white,
                          backgroundImage: (_cloudinaryImageUrl != null && _cloudinaryImageUrl != "")
                              ? NetworkImage(_cloudinaryImageUrl!)
                              : const AssetImage('assets/images/default_doc.png') as ImageProvider,
                        ),
                        SizedBox(width: sWidth * 0.04),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Dr. ${_doctorName ?? 'Loading...'}", style: TextStyle(fontSize: sWidth * 0.045, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: sWidth * 0.06),
                                SizedBox(width: sWidth * 0.01),
                                const Text("5", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sHeight * 0.025),
                  _buildSectionTitle("Select date", sWidth),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.all(sWidth * 0.04),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.calendar_month, color: Colors.green[800], size: sWidth * 0.07),
                            SizedBox(width: sWidth * 0.03),
                            Text(_formattedDateText, style: TextStyle(fontSize: sWidth * 0.04)),
                          ]),
                          const Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: sHeight * 0.025),
                  _buildSectionTitle("Select Time", sWidth),

                  _isLoadingSlots
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: _availableSlots.isEmpty && _selectedDate != null
                        ? [const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("No slots available for this day.", style: TextStyle(color: Colors.red)),
                    )]
                        : _availableSlots.map((slot) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTimeSlot = slot),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _selectedTimeSlot == slot ? Colors.green[300] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(children: [Text(slot, style: TextStyle(fontSize: sWidth * 0.04))]),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: sHeight * 0.02),
                  _buildSectionTitle("Consultaion Type", sWidth),
                  Row(
                    children: [
                      Expanded(child: _buildTypeBtn("Message", Icons.message, sWidth)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildTypeBtn("Voice", Icons.phone, sWidth)),
                    ],
                  ),

                  SizedBox(height: sHeight * 0.02),
                  _buildSectionTitle("name", sWidth),
                  _buildInput(_nameController, "Enter your name", sWidth),

                  SizedBox(height: sHeight * 0.02),
                  _buildSectionTitle("Describe Your Concern", sWidth),
                  _buildInput(_concernController, "How are you feeling?", sWidth, lines: 3),

                  SizedBox(height: sHeight * 0.04),
                  _buildMainBtn("payment-methods", Colors.green[800]!, sWidth, sHeight, () {}),
                  const SizedBox(height: 15),
                  _buildMainBtn("Book Apoinment", const Color(0xFF5DB004), sWidth, sHeight, _saveAppointmentToPendingApprovals),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildSectionTitle(String text, double w) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.bold)));

  Widget _buildTypeBtn(String type, IconData icon, double w) {
    bool sel = _selectedConsultationType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedConsultationType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: sel ? Colors.green[200] : Colors.grey[300], borderRadius: BorderRadius.circular(15)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(type)]),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, double w, {int lines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
      child: TextField(controller: ctrl, maxLines: lines, decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(15))),
    );
  }

  Widget _buildMainBtn(String text, Color col, double w, double h, VoidCallback press) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: press,
        style: ElevatedButton.styleFrom(backgroundColor: col, padding: EdgeInsets.symmetric(vertical: h * 0.018), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: w * 0.045, fontWeight: FontWeight.bold)),
      ),
    );
  }
}