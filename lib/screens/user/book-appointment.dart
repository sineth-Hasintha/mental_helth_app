import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'greeen-scren.dart';
// Payment පිටුව ඇති ගොනුව මෙහි import කරන්න
import 'select-payment-methord.dart';

class BookAppointmentPage extends StatefulWidget {
  // මෙම පිටුවට ඇතුළු වන විට වෛද්‍යවරයාගේ නම සහ ID එක අනිවාර්යයෙන්ම තිබිය යුතුයි.
  final String doctorName;
  final String doctorId;

  const BookAppointmentPage({
    super.key,
    required this.doctorName,
    required this.doctorId,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  // --- විචල්‍යයන් සහ පාලකයන් ---
  DateTime selectedDate = DateTime.now();
  int? selectedIndex;
  String? selectedTimeValue;
  String dayOfWeek = DateFormat('EEEE').format(DateTime.now());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _concernController = TextEditingController();

  // --- දුරකථන ඇමතුම් ලබා ගැනීම ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // --- SMS පණිවිඩ යැවීම ---
  Future<void> _sendSMS(String phoneNumber) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': 'Hello, I would like to talk with you.',
      },
    );
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      debugPrint('SMS යැවීමට නොහැක: $e');
    }
  }

  // --- දින දර්ශනය පෙන්වීම ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dayOfWeek = DateFormat('EEEE').format(picked);
        selectedIndex = null;
        selectedTimeValue = null;
      });
    }
  }

  // --- Appointment එක Firebase වෙත යැවීම ---
  Future<void> _validateAndBook() async {
    if (_nameController.text.isEmpty || selectedTimeValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("කරුණාකර ඔබේ නම ඇතුළත් කර වේලාවක් තෝරන්න!"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('pending-Approvals').add({
        'name': _nameController.text.trim(),
        'date': DateFormat('dd MMM yyyy').format(selectedDate),
        'time-and-venue': selectedTimeValue,
        'Describe Your Concern': _concernController.text.trim(),
        'Doctor-ID': widget.doctorId,
        'doctorName': widget.doctorName,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GreenSplashScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ගැටලුවක් පවතී: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sWidth = MediaQuery.of(context).size.width;
    final double sHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Book a appointment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // පසුබිම් අලංකරණය
          Positioned(
            right: -sWidth * 0.2, top: sHeight * 0.1,
            child: Container(width: sWidth * 0.5, height: sWidth * 0.5, decoration: BoxDecoration(color: const Color(0xFF5DB004).withOpacity(0.7), shape: BoxShape.circle)),
          ),
          Positioned(
            left: -sWidth * 0.2, bottom: -sHeight * 0.05,
            child: Container(width: sWidth * 0.6, height: sWidth * 0.6, decoration: BoxDecoration(color: const Color(0xFF5DB004).withOpacity(0.7), shape: BoxShape.circle)),
          ),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // වෛද්‍යවරයාගේ Card එක
                Container(
                  margin: EdgeInsets.symmetric(horizontal: sWidth * 0.05, vertical: sHeight * 0.01),
                  padding: EdgeInsets.all(sWidth * 0.03),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF0070C0), width: 2)),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 25, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
                      const SizedBox(width: 15),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Dr. ${widget.doctorName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const Row(children: [Icon(Icons.star, color: Colors.amber, size: 18), Text(" 5")])
                          ]
                      ),
                    ],
                  ),
                ),

                _buildLabel("Select date", sWidth),
                _buildDatePicker(context, sWidth, sHeight),

                _buildLabel("Select Time", sWidth),
                _buildTimePicker(sWidth, sHeight),

                _buildLabel("Consultation Type", sWidth),
                Row(children: [
                  _buildTypeButton("Message", "assets/images/message.png", sWidth, sHeight, () => _sendSMS('0764314705')),
                  _buildTypeButton("Voice", "assets/images/coll.png", sWidth, sHeight, () => _makePhoneCall('0764314705')),
                ]),

                _buildLabel("Name", sWidth),
                _buildTextField(_nameController, "Enter your name", sWidth),

                _buildLabel("Describe Your Concern (Optional)", sWidth),
                _buildTextField(_concernController, "Briefly describe how you are feeling...", sWidth, maxLines: 2),

                SizedBox(height: sHeight * 0.03),

                // ඔබ ඉල්ලූ පරිදි නිවැරදි කළ Payment පිටුවට යන බොත්තම (Line 192 අවට)
                _buildBottomButton("payment-methods", const Color(0xFF5DB004), sWidth, sHeight, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSelectionPage(
                        // දැනට සිටින වෛද්‍යවරයාගේ විස්තර Payment පිටුවට යැවීම
                        doctorName: widget.doctorName,
                        doctorId: widget.doctorId,
                      ),
                    ),
                  );
                }),

                _buildBottomButton("Book Appointment", const Color(0xFF5DB004), sWidth, sHeight, _validateAndBook),

                SizedBox(height: sHeight * 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helper Functions ---

  Widget _buildLabel(String text, double sWidth) => Padding(padding: EdgeInsets.only(left: sWidth * 0.05, top: 15, bottom: 5), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)));

  Widget _buildDatePicker(BuildContext context, double sWidth, double sHeight) => GestureDetector(
    onTap: () => _selectDate(context),
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: sWidth * 0.05, vertical: sHeight * 0.005),
      padding: EdgeInsets.all(sHeight * 0.018),
      decoration: BoxDecoration(color: Colors.grey[350], borderRadius: BorderRadius.circular(10)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [const Icon(Icons.calendar_month, color: Colors.green), const SizedBox(width: 10), Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold))]),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ]
      ),
    ),
  );

  Widget _buildTimePicker(double sWidth, double sHeight) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('doctor-sha').where('Doctor-ID', isEqualTo: widget.doctorId).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text("වේලාවන් හමු නොවීය."));

      var docData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
      if (docData.containsKey(dayOfWeek)) {
        List<dynamic> times = docData[dayOfWeek];
        return Column(
          children: List.generate(times.length, (index) {
            bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => setState(() { selectedIndex = index; selectedTimeValue = times[index].toString(); }),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: sWidth * 0.05, vertical: sHeight * 0.005),
                padding: EdgeInsets.all(sHeight * 0.018),
                decoration: BoxDecoration(color: isSelected ? Colors.green[200] : Colors.grey[350], borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Hospital Location", style: TextStyle(color: Colors.black54)), Text(times[index].toString(), style: const TextStyle(fontWeight: FontWeight.bold))]),
              ),
            );
          }),
        );
      }
      return const Padding(padding: EdgeInsets.all(20), child: Text("මෙම දවසේ වේලාවන් නොමැත."));
    },
  );

  Widget _buildTextField(TextEditingController controller, String hint, double sWidth, {int maxLines = 1}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: sWidth * 0.05),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[350], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
    ),
  );

  Widget _buildTypeButton(String title, String imagePath, double sWidth, double sHeight, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: sWidth * 0.05, vertical: 5),
        padding: EdgeInsets.symmetric(vertical: sHeight * 0.015),
        decoration: BoxDecoration(color: Colors.grey[350], borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset(imagePath, width: 20, height: 20), const SizedBox(width: 8), Text(title)]),
      ),
    ),
  );

  Widget _buildBottomButton(String title, Color color, double sWidth, double sHeight, VoidCallback onTap) => Padding(
    padding: EdgeInsets.symmetric(horizontal: sWidth * 0.1, vertical: sHeight * 0.008),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: Size(double.infinity, sHeight * 0.06), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}