import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/user_login_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isEditing = false;
  String _profileImage = '👤'; // Default profile emoji

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showSubcategorySnackbar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$title is coming soon!'),
      duration: Duration(seconds: 2),
    ),
  );
}


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      _nameController.text = '';
      _emailController.text = '';
      _phoneController.text = '';
      _addressController.text = '';
      return;
    }

    final safeEmail = user.email!.replaceAll('.', ',');
    try {
      final doc = await _firestore.collection('users').doc(safeEmail).get();
      final data = doc.data();
      _nameController.text = (data?['name'] ?? user.displayName ?? '').toString();
      _emailController.text = (data?['email'] ?? user.email ?? '').toString();
      _phoneController.text = (data?['phone'] ?? '').toString();
      _addressController.text = (data?['address'] ?? '').toString();
    } catch (_) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isEditing = false;
    });

    final user = _auth.currentUser;
    if (user != null) {
      final safeEmail = user.email!.replaceAll('.', ',');
      await _firestore.collection('users').doc(safeEmail).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? user.email : _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _changeProfileImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileImageOption('👦', 'Boy'),
            _buildProfileImageOption('👧', 'Girl'),
            _buildProfileImageOption('👨', 'Man'),
            _buildProfileImageOption('👩', 'Woman'),
            _buildProfileImageOption('👶', 'Baby'),
            _buildProfileImageOption('👤', 'Default'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageOption(String emoji, String label) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      onTap: () {
        setState(() {
          _profileImage = emoji;
        });
        Navigator.pop(context);
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserLoginScreen()),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _isEditing ? _saveProfile : _toggleEditing,
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 32),
            // Profile Form
            _buildProfileForm(),
            const SizedBox(height: 32),
            // Quick Links
            _buildQuickLinks(),
            const SizedBox(height: 32),
            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  _profileImage,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
            if (_isEditing)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: IconButton(
                  onPressed: _changeProfileImage,
                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFormField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Email Address',
            controller: _emailController,
            icon: Icons.email_outlined,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Phone Number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Address',
            controller: _addressController,
            icon: Icons.location_on_outlined,
            enabled: _isEditing,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.tertiary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : Colors.white,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Links',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildLinkTile(Icons.shopping_bag_outlined, 'My Orders', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
          }),
          _buildLinkTile(Icons.favorite_border, 'My Wishlist', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
          }),
          _buildLinkTile(Icons.location_on_outlined, 'My Addresses', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()));
          }),
          _buildLinkTile(Icons.payment_outlined, 'Payment Methods', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
          }),
          _buildLinkTile(Icons.support_agent, 'Support', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
