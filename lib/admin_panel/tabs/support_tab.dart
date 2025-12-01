import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class SupportTab extends StatelessWidget {
  final FirestoreService firestoreService;
  SupportTab({required this.firestoreService});

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF7E57C2))),
          SizedBox(height: 16),
          Text('Loading Tickets...', style: TextStyle(color: Color(0xFF7E57C2))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 64, color: Colors.grey[400]),
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
                'Support Tickets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage customer support requests',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        
        // Tickets List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getAllSupportTickets(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return _buildLoadingIndicator();
              if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No support tickets found');
              
              final tickets = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final t = tickets[index];
                  return _buildSupportCard(t);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(QueryDocumentSnapshot t) {
    Color statusColor = Colors.orange;
    if (t['status'] == 'in_progress') statusColor = const Color(0xFFF7C9D1);
    if (t['status'] == 'closed') statusColor = Colors.green;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.help_outline, color: Color(0xFF7E57C2)),
        title: Text(t['subject'], style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t['description'] ?? 'No description', maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                t['status'].toString().toUpperCase().replaceAll('_', ' '),
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: DropdownButton<String>(
          value: t['status'],
          items: ['open', 'in_progress', 'closed']
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.replaceAll('_', ' ')),
                  ))
              .toList(),
          onChanged: (value) => firestoreService.updateTicketStatus(t.id, value!),
        ),
      ),
    );
  }
}
