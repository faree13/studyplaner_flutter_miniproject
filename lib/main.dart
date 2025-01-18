import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:study_planner/home_screen.dart';
import 'package:study_planner/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCpCj3vtgPXyEPas2BxLFD3nshFHH3Ubcs",
      authDomain: "studyplanner-38d0b.firebaseapp.com",
      projectId: "studyplanner-38d0b",
      storageBucket: "studyplanner-38d0b.firebasestorage.app",
      messagingSenderId: "291608509598",
      appId: "1:291608509598:android:01790d9059e6177d724f8f",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "StudyPlanner",
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: _auth.currentUser != null ? HomeScreen() : LoginScreen(),
    );
  }
}
