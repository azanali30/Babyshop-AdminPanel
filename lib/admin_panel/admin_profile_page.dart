import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  String _adminInitial = 'A';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  /// Fetch admin data from Firestore
  void _loadAdminData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Load email from Firebase Auth
        _emailController.text = user.email ?? '';

        // Load name from Firestore
        final adminDoc =
            await _firestore.collection('admins').doc(user.uid).get();

        if (adminDoc.exists && adminDoc.data() != null) {
          final adminData = adminDoc.data()!;
          final String name = adminData['name'] ?? '';
          _nameController.text = name;
          setState(() {
            _adminInitial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
          });
        } else {
          setState(() {
            _adminInitial = user.email != null && user.email!.isNotEmpty
                ? user.email![0].toUpperCase()
                : 'A';
          });
        }
      }
    } catch (e) {
      print('Error loading admin data: $e');
    }
  }

  /// Update profile data
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      // Update name in Firestore
      if (_nameController.text.isNotEmpty) {
        await _firestore.collection('admins').doc(user.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          _adminInitial = _nameController.text[0].toUpperCase();
        });
      }

      // Update email in Firebase Auth
      if (_emailController.text.isNotEmpty &&
          _emailController.text != user.email) {
        await user.verifyBeforeUpdateEmail(_emailController.text);
      }

      // Update password
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = 'Passwords do not match';
            _isLoading = false;
          });
          return;
        }
        if (_passwordController.text.length < 6) {
          setState(() {
            _errorMessage = 'Password must be at least 6 characters';
            _isLoading = false;
          });
          return;
        }
        await user.updatePassword(_passwordController.text);
      }

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear password fields
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6F4),
      appBar: AppBar(
        title: Text(
          'Admin Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF6A8EAE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFFFD6DC),
                      radius: 30,
                      child: Text(
                        _adminInitial,
                        style: TextStyle(
                          color: Color(0xFF6A8EAE),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Profile',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Update your profile information',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Name
            _buildTextField(_nameController, 'Full Name', Icons.person),

            // Email
            _buildTextField(_emailController, 'Email', Icons.email),

            // Password
            _buildTextField(_passwordController, 'New Password', Icons.lock,
                obscureText: true),

            // Confirm Password
            _buildTextField(
                _confirmPasswordController, 'Confirm New Password', Icons.lock,
                obscureText: true),

            if (_errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.redAccent, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 30),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF7C9D1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Update Profile',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget for TextFields
  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {bool obscureText = false}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Color(0xFFF7C9D1)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
