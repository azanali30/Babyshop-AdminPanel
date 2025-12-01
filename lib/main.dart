import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'auth/login_screen.dart';
import 'admin_panel/admin_panel.dart';   // <-- sahi import
import 'ui/design_system.dart';

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

      theme: babyTheme,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFFFFA), Color(0xFFFDF7F9)],
            ),
          ),
          child: child,
        );
      },

      
      home:  SplashScreen(), 

      routes: {
        '/login': (context) => LoginScreen(),
        '/admin': (context) => AdminPanel(),  // <-- admin panel route
      },
    );
  }
}
