import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'auth_service.dart';
import 'login_screen.dart';
import '../user/main_wrapper.dart';
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

  /// ================== Email/Password Login ==================
  Future<void> loginUser() async {
    setState(() => _isLoading = true);
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      final safeEmail = email.replaceAll('.', ',');

      // Firestore check
      final doc = await _firestore.collection("users").doc(safeEmail).get();
      if (!doc.exists) {
        showError("User not found in database");
        setState(() => _isLoading = false);
        return;
      }

      // Firebase Authentication
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Navigate to MainWrapper (shows bottom navigation)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapper()),
      );
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ================== Google Login ==================
  Future<void> googleLogin() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && userCredential.user != null) {
        String safeEmail = userCredential.user!.email!.replaceAll('.', ',');
        await _firestore.collection("users").doc(safeEmail).set({
          "email": userCredential.user!.email,
          "name": userCredential.user!.displayName,
          "createdAt": DateTime.now(),
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainWrapper()),
        );
      } else {
        showError("Google Sign-In cancelled");
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ================== Facebook Login ==================
  Future<void> facebookLogin() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await _auth.signInWithCredential(facebookCredential);

        String safeEmail = _auth.currentUser!.email!.replaceAll('.', ',');
        await _firestore.collection("users").doc(safeEmail).set({
          "email": _auth.currentUser!.email,
          "name": _auth.currentUser!.displayName,
          "createdAt": DateTime.now(),
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainWrapper()),
        );
      } else {
        showError("Facebook login cancelled or failed");
      }
    } catch (e) {
      showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ================== Helper: Show error ==================
  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFF7C9D1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "User Sign In",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF7C9D1),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Email
                  TextField(
                    controller: emailController,
                    cursorColor: const Color(0xFFF7C9D1),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFF7C9D1)),
                      labelText: "Email Address",
                      labelStyle: const TextStyle(color: Color(0xFFF7C9D1)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF7C9D1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    cursorColor: const Color(0xFFF7C9D1),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFF7C9D1)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFF7C9D1),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Color(0xFFF7C9D1)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF7C9D1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(
                        color: Color(0xFFF7C9D1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7C9D1),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isLoading ? null : loginUser,
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
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Or continue with",
                    style: TextStyle(
                      color: Color(0xFFF7C9D1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Social Login Buttons
                  Row(
                    children: [
                      // Google
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : googleLogin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Iconsax.gallery, color: Colors.red, size: 20);
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text("Google", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Apple placeholder
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Add Apple login
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.apple, size: 20, color: Colors.black),
                                SizedBox(width: 8),
                                Text("Apple", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),


                  const SizedBox(height: 20),

                  // Create Account
                  GestureDetector(
                    onTap: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Color(0xFFF7C9D1), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Admin Login
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF7C9D1)),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFF7C9D1).withOpacity(0.1),
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
                          Icon(Iconsax.security, color: const Color(0xFFF7C9D1), size: 20),
                          const SizedBox(width: 8),
                          Text("Admin Login", style: TextStyle(color: const Color(0xFFF7C9D1), fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
