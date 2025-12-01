import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firestore_service.dart';
import '../auth/login_screen.dart';
import 'admin_profile_page.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/products_tab.dart';
import 'tabs/orders_tab.dart';
import 'tabs/users_tab.dart';
import 'tabs/reviews_tab.dart';
import 'tabs/support_tab.dart';
import 'tabs/categories_tab.dart';
import 'tabs/payments_tab.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService firestoreService = FirestoreService();

  int _currentIndex = 0;
  String _adminName = 'A';
  String _adminEmail = '';

  // Updated to match login screen color theme
  final Color _primaryColor = Color(0xFFF7C9D1);
  final Color _backgroundColor = Colors.transparent;
  final Color _accentColor = Color(0xFFF7C9D1).withOpacity(0.1);
  final Color _iconColor = Color(0xFFF7C9D1);
  final Color _textColor = Color(0xFFF7C9D1);
  final Color _cardColor = Colors.white;

  late final List<Widget> _bottomTabs;
  late final List<Widget> _drawerTabs;
  final List<String> _drawerTabNames = ['Reviews', 'Support', 'Categories', 'Payments'];

  @override
  void initState() {
    super.initState();

    // Initialize bottom tabs
    _bottomTabs = [
      DashboardTab(firestoreService: firestoreService),
      ProductsTab(firestoreService: firestoreService),
      OrdersTab(firestoreService: firestoreService),
      UsersTab(firestoreService: firestoreService),
    ];

    // Initialize drawer tabs
    _drawerTabs = [
      ReviewsTab(firestoreService: firestoreService),
      SupportTab(firestoreService: firestoreService),
      CategoriesTab(firestoreService: firestoreService),
      PaymentsTab(firestoreService: firestoreService),
    ];

    _loadAdminData();
  }

  void _loadAdminData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _adminEmail = user.email ?? '';
        final adminDoc =
            await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();

        if (adminDoc.exists && adminDoc.data() != null) {
          final data = adminDoc.data()!;
          final name = data['name'] ?? 'Admin';
          _adminName = name.isNotEmpty ? name[0].toUpperCase() : 'A';
        } else {
          _adminName = _adminEmail.isNotEmpty ? _adminEmail[0].toUpperCase() : 'A';
        }
        setState(() {});
      }
    } catch (e) {
      print('Error loading admin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.admin_panel_settings, color: _primaryColor, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Management Console',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: _primaryColor,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [_buildProfileDropdown()],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _bottomTabs,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: _cardColor,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 4,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }

  // ---------------- Drawer ----------------
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: _backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            _buildDrawerSectionHeader('MAIN SECTIONS'),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', 0, true),
            _buildDrawerItem(Icons.shopping_basket, 'Products', 1, true),
            _buildDrawerItem(Icons.receipt_long, 'Orders', 2, true),
            _buildDrawerItem(Icons.people, 'Users', 3, true),
            _buildDrawerSectionHeader('MANAGEMENT'),
            ...List.generate(_drawerTabs.length, (i) {
              return _buildDrawerItem(_getDrawerIcon(i), _drawerTabNames[i], 4 + i, false);
            }),
            _buildDrawerSectionHeader('SETTINGS'),
            _buildDrawerItem(Icons.person, 'Profile', -1, false, isProfile: true),
            _buildDrawerItem(Icons.logout, 'Logout', -2, false, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: _primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: Text(_adminName,
                style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          SizedBox(height: 12),
          Text('Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(_adminEmail,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 20, bottom: 8),
      child: Text(title, 
          style: TextStyle(
            color: _primaryColor.withOpacity(0.7), 
            fontSize: 12, 
            fontWeight: FontWeight.w600
          )),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, bool isBottomNav,
      {bool isProfile = false, bool isLogout = false}) {
    bool isSelected = isBottomNav && _currentIndex == index;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? _accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? _primaryColor : 
                isProfile ? _primaryColor :
                isLogout ? Colors.red.shade600 : 
                _textColor.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? _primaryColor : 
                  isProfile ? _primaryColor :
                  isLogout ? Colors.red.shade600 : 
                  _textColor.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (isProfile) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProfilePage()));
          } else if (isLogout) {
            _showLogoutDialog();
          } else if (isBottomNav) {
            setState(() => _currentIndex = index);
          } else {
            _navigateToDrawerTab(index - 4);
          }
        },
      ),
    );
  }

  void _navigateToDrawerTab(int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(_drawerTabNames[tabIndex]),
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
          ),
          body: _drawerTabs[tabIndex],
        ),
      ),
    );
  }

  IconData _getDrawerIcon(int index) {
    switch (index) {
      case 0:
        return Icons.star;
      case 1:
        return Icons.support_agent;
      case 2:
        return Icons.category;
      case 3:
        return Icons.payment;
      default:
        return Icons.more_horiz;
    }
  }

  Widget _buildProfileDropdown() {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(_adminName, 
            style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
      ),
      onSelected: (value) {
        if (value == 'profile') Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProfilePage()));
        if (value == 'logout') _showLogoutDialog();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'profile', 
          child: Row(
            children: [
              Icon(Icons.person, color: _primaryColor),
              SizedBox(width: 8),
              Text('Profile Settings'),
            ],
          )
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade600),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          )
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout Confirmation', style: TextStyle(color: _primaryColor)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancel', style: TextStyle(color: _primaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
            ),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => LoginScreen()), 
                (_) => false
              );
            },
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
