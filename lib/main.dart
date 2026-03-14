import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase engine එක
import 'firebase_options.dart'; // Firebase configure කළාම හැදුණු file එක
import 'package:animated_calculator/screens/othanti/fist.dart'; // ඔයාගේ First Page එක තියෙන තැන

void main() async {
  // Flutter engine එක සහ Firebase සම්බන්ධ කිරීමට මේ පේළි 2 අනිවාර්යයි
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindspace', // ඔයාගේ App එකේ නම

      // ඇප් එක පටන් ගන්න කොටම පෙන්වන පිටුව (Home)
      // මම මෙතන 'Fist()' කියලා දුන්නේ ඔයාගේ fist.dart එකේ තියෙන Class එකේ නමයි.
      // ඒක රතු ඉරක් ආවොත්, ඒ වෙනුවට fist.dart එකේ තියෙන ඇත්තම Class නම දෙන්න.
      home: const SplashPage(),
    );
  }
}