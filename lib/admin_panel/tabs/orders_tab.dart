import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class OrdersTab extends StatelessWidget {
  final FirestoreService firestoreService;
  OrdersTab({required this.firestoreService});

  // Updated to match login screen color theme
  final Color _primaryColor = Color(0xFFF7C9D1);

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(_primaryColor)),
          SizedBox(height: 16),
          Text('Loading Orders...', style: TextStyle(color: _primaryColor)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
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
                'Order Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage customer orders and track status',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        
        // Orders List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getOrders(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return _buildLoadingIndicator();
              if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No orders found');
              
              final orders = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final o = orders[index];
                  return _buildOrderCard(o, context);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot o, BuildContext context) {
    final data = o.data() as Map<String, dynamic>? ?? const {};
    Color statusColor = Colors.orange;
    if ((data['status'] ?? 'pending') == 'shipped') statusColor = const Color(0xFFF7C9D1);
    if ((data['status'] ?? 'pending') == 'delivered') statusColor = Colors.green;

    String currentStatus = (data['status'] ?? 'pending').toString();
    if (!['pending', 'shipped', 'delivered'].contains(currentStatus)) {
      currentStatus = 'pending';
    }

    final dynamic rawItems = data['items'];
    List<Map<String, dynamic>> items = [];
    if (rawItems is List) {
      try {
        items = List<Map<String, dynamic>>.from(rawItems);
      } catch (_) {
        items = [];
      }
    } else if (rawItems is Map<String, dynamic>) {
      items = [rawItems];
    }
    final String firstImage = items.isNotEmpty ? (items.first['image'] ?? '').toString() : '';
    final List<String> productIds = items
        .map((e) => e['productId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    final dynamic emailRaw = data['email'];
    final String email = (emailRaw is String) ? emailRaw : '';
    final String safeEmail = email.isNotEmpty ? email.replaceAll('.', ',') : '';
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: firstImage.isNotEmpty
                  ? Image.network(firstImage, fit: BoxFit.cover)
                  : Icon(Icons.shopping_cart, color: Theme.of(context).colorScheme.secondary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${o.id.substring(0, 8)}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.tertiary),
                      ),
                      DropdownButton<String>(
                        value: currentStatus,
                        items: ['pending', 'shipped', 'delivered']
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                        onChanged: (value) => firestoreService.updateOrderStatus(o.id, value!),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text('₹${data['total'] ?? 0}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(currentStatus.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _infoBadge(context, Icons.person_outline, 'User', (data['userId'] ?? 'N/A').toString()),
                      _infoBadge(context, Icons.mail_outline, 'Email', email.isNotEmpty ? email : 'N/A'),
                      if (productIds.isNotEmpty)
                        _infoBadge(context, Icons.shopping_bag_outlined, 'Products', productIds.join(', ')),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _infoBadge(context, Icons.place_outlined, 'Address', (data['address'] ?? 'N/A').toString())),
                    ],
                  ),
                  SizedBox(height: 6),
                  safeEmail.isNotEmpty
                      ? FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(safeEmail).get(),
                          builder: (context, snap) {
                            String phone = '';
                            if (snap.hasData && snap.data?.data() != null) {
                              final map = snap.data!.data() as Map<String, dynamic>;
                              phone = (map['phone'] ?? '').toString();
                            }
                            return _infoBadge(context, Icons.phone_outlined, 'Phone', phone.isNotEmpty ? phone : 'N/A');
                          },
                        )
                      : _infoBadge(context, Icons.phone_outlined, 'Phone', 'N/A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  Widget _infoBadge(BuildContext context, IconData icon, String label, String value) {
    final Color base = Theme.of(context).colorScheme.primary;
    final Color bg = base.withOpacity(0.10);
    final bool isNA = value.trim().isEmpty || value.trim() == 'N/A';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: base.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: base),
          SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              color: isNA ? Colors.grey[700] : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
