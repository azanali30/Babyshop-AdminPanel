import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/user_login_screen.dart';

import 'auth/login_screen.dart';
import 'admin_panel/admin_panel.dart';   // <-- sahi import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShop',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: Color(0xFF6A8EAE),
        scaffoldBackgroundColor: Color(0xFFF8F6F4),
        fontFamily: 'Roboto',
      ),

      
      home: const UserLoginScreen(), // App start → Login

      routes: {
        '/login': (context) => LoginScreen(),
        '/admin': (context) => AdminPanel(),  // <-- admin panel route
      },
    );
  }
}
