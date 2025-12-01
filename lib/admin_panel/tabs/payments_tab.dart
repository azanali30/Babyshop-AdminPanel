import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class PaymentsTab extends StatelessWidget {
  final FirestoreService firestoreService;
  PaymentsTab({required this.firestoreService});

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
                'Payment Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage payment transactions',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Payments List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getPayments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return Center(child: Text("No payments found"));

              final payments = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  return _buildPaymentCard(payments[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(QueryDocumentSnapshot payment) {
    final data = payment.data() as Map<String, dynamic>;

    final status = data['status'] ?? 'pending';
    final amount = data['amount'] ?? 0;
    final method = data['method'] ?? 'Unknown';

    Color statusColor = Colors.orange;
    if (status == 'paid') statusColor = Colors.green;
    if (status == 'failed') statusColor = Colors.red;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.payment, size: 32, color: Colors.teal),
        title: Text("Rs $amount"),
        subtitle: Text("${method.toUpperCase()} • ${payment.id.substring(0, 8)}"),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
