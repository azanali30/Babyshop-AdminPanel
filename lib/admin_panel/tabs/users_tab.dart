import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';
import '../user_detail_page.dart';

class UsersTab extends StatelessWidget {
  final FirestoreService firestoreService;
  UsersTab({required this.firestoreService});

  // Updated to match login screen color theme
  final Color _primaryColor = Color(0xFFF7C9D1);

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(_primaryColor)),
          SizedBox(height: 16),
          Text('Loading Users...', style: TextStyle(color: _primaryColor)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View registered customers',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        
        // Users List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getUsers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return _buildLoadingIndicator();
              if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No users found');
              
              final users = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final u = users[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.person, color: _primaryColor),
                      title: Text(u['name'], style: TextStyle(fontWeight: FontWeight.w600, color: _primaryColor)),
                      subtitle: Text(u['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.chevron_right, color: _primaryColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailPage(userDoc: u),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailPage(userDoc: u),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
