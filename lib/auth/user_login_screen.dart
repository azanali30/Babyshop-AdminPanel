import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';

import 'auth_service.dart';
import 'login_screen.dart';
import '../user/user_screen.dart';
import 'user_registration_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

Future<void> loginUser() async {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  try {
    final safeEmail = email.replaceAll('.', ',');
    
    // Firestore me check
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(safeEmail)
        .get();

    if (!doc.exists) {
      showError("User not found in database");
      return;
    }

    // Firebase Authentication
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Redirect → User Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserScreen()),
    );
  } catch (e) {
    showError(e.toString());
  }
}


Future<void> googleLogin() async {
  try {
    final userCredential = await _authService.signInWithGoogle();
    if (userCredential != null && userCredential.user != null) {
      // Email ko safe doc ID me convert karo
      String safeEmail = userCredential.user!.email!.replaceAll('.', ',');

      // Firestore me save/update user
      await FirebaseFirestore.instance
          .collection("users")
          .doc(safeEmail)
          .set({
        "email": userCredential.user!.email,
        "name": userCredential.user!.displayName,
        "createdAt": DateTime.now(),
      }, SetOptions(merge: true));

      // Redirect → User Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserScreen()),
      );
    } else {
      showError("Google Sign-In cancelled");
    }
  } catch (e) {
    showError(e.toString());
  }
}

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.pink[300],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header with Baby Theme
              _buildHeader(),
              const SizedBox(height: 40),
              
              // Login Form
              _buildLoginForm(),
              const SizedBox(height: 30),
              
              // Social Login
              _buildSocialLogin(),
              const SizedBox(height: 30),
              
              // Footer Links
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Baby-themed icon/logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4EC),
            borderRadius: BorderRadius.circular(60),
          ),
          child: const Icon(
            Icons.child_care,
            size: 60,
            color: Color(0xFFEC407A),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.pink[400],
            fontFamily: 'ComicNeue',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sign in to continue your parenting journey",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "Email Address",
              labelStyle: TextStyle(color: Colors.pink[400]),
              prefixIcon: Icon(Iconsax.sms, color: Colors.pink[300]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        const SizedBox(height: 16),
        
        // Password Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(color: Colors.pink[400]),
              prefixIcon: Icon(Iconsax.lock, color: Colors.pink[300]),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                  color: Colors.pink[300],
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Login Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : loginUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC407A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
          ),
        ),
      ],
    );
  }
  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.grey[300]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Or continue with",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.grey[300]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Google Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _isLoading ? null : googleLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Iconsax.gallery, color: Colors.red);
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  "Continue with Google",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        // Create Account
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
            );
          },
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: "New to our app? "),
                TextSpan(
                  text: "Create Account",
                  style: TextStyle(
                    color: Colors.pink[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Admin Login
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.pink[100]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.pink[50],
          ),
          child: TextButton(
            onPressed: _isLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.security, color: Colors.pink[400], size: 20),
                const SizedBox(width: 8),
                Text(
                  "Admin Login",
                  style: TextStyle(
                    color: Colors.pink[400],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}