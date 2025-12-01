import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Orders', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
      ),
      body: _OrdersBody(),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please login to view your orders'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No orders yet', style: TextStyle(color: Colors.grey[600])),
          );
        }

        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final ta = (a['createdAt'] as Timestamp?);
          final tb = (b['createdAt'] as Timestamp?);
          return (tb?.millisecondsSinceEpoch ?? 0).compareTo(ta?.millisecondsSinceEpoch ?? 0);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index];
            final data = d.data() as Map<String, dynamic>;
            final total = (data['total'] ?? 0);
            final status = (data['status'] ?? 'pending').toString();
            final items = (data['items'] as List?) ?? const [];
            final createdAtTs = data['createdAt'] as Timestamp?;
            final created = createdAtTs?.toDate();

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #${d.id.substring(0, 6)}', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600)),
                        _statusChip(context, status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Items: ${items.length}', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Text('Total: PKR $total', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF773D44))),
                    const SizedBox(height: 4),
                    if (created != null)
                      Text('Placed: ${created.toLocal()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    Color bg;
    switch (status) {
      case 'pending':
        bg = Colors.orange;
        break;
      case 'processing':
        bg = Theme.of(context).colorScheme.primary;
        break;
      case 'shipped':
        bg = Theme.of(context).colorScheme.primary;
        break;
      case 'delivered':
        bg = Colors.green;
        break;
      case 'cancelled':
        bg = Colors.red;
        break;
      default:
        bg = Theme.of(context).colorScheme.secondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: bg)),
      child: Text(status.toUpperCase(), style: TextStyle(color: bg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
