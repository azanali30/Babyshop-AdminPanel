import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot userDoc;
  const UserDetailPage({super.key, required this.userDoc});

  @override
  Widget build(BuildContext context) {
    final data = userDoc.data() as Map<String, dynamic>? ?? const {};
    final name = (data['name'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final phone = (data['phone'] ?? '').toString();
    final address = (data['address'] ?? '').toString();
    final role = (data['role'] ?? '').toString();
    final safeEmail = email.replaceAll('.', ',');

    const Color primary = Color(0xFFF7C9D1);

    Widget labeledTile(IconData icon, String label, String value) {
      return ListTile(
        title: Text(label, style: const TextStyle(color: primary, fontWeight: FontWeight.w600)),
        subtitle: Text(value.isNotEmpty ? value : 'N/A'),
      );
    }

    Widget countBadge(String label, Stream<QuerySnapshot> stream) {
      return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Text(count.toString(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primary,
                      child: Text(
                        name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.isNotEmpty ? name : 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(email, style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  labeledTile(Icons.badge, 'Role', role),
                  const Divider(height: 1),
                  labeledTile(Icons.phone, 'Phone', phone),
                  const Divider(height: 1),
                  labeledTile(Icons.home, 'Address', address),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                countBadge('Orders', FirebaseFirestore.instance.collection('orders').where('email', isEqualTo: email).snapshots()),
                countBadge('Cart', FirebaseFirestore.instance.collection('users').doc(safeEmail).collection('cart').snapshots()),
                countBadge('Wishlist', FirebaseFirestore.instance.collection('users').doc(safeEmail).collection('wishlist').snapshots()),
                countBadge('Addresses', FirebaseFirestore.instance.collection('users').doc(safeEmail).collection('addresses').snapshots()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
