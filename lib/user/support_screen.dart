import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firestore_service.dart';
import '../auth/user_login_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _type = 'Question';
  bool _submitting = false;

  final _service = FirestoreService();

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const UserLoginScreen()));
      return;
    }
    if (_subjectController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill subject and message')));
      return;
    }
    setState(() => _submitting = true);
    await _service.submitSupportTicket(
      subject: _subjectController.text.trim(),
      description: _messageController.text.trim(),
      type: _type,
    );
    setState(() => _submitting = false);
    _subjectController.clear();
    _messageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket submitted')));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final safeEmail = user?.email?.replaceAll('.', ',');
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ask, Complain, or Give Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'Question', child: Text('Question')),
                  DropdownMenuItem(value: 'Complaint', child: Text('Complaint')),
                  DropdownMenuItem(value: 'Feedback', child: Text('Feedback')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'Question'),
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Submit Ticket', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Your Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (user == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Please login to view your tickets'),
                )
              else
                SizedBox(
                  height: 400,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('support')
                        .where('email', isEqualTo: user.email)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return Center(child: Text('No tickets', style: TextStyle(color: Colors.grey[600])));
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final d = docs[index];
                          final data = d.data() as Map<String, dynamic>;
                          final subject = (data['subject'] ?? '').toString();
                          final desc = (data['description'] ?? '').toString();
                          final status = (data['status'] ?? 'open').toString();
                          Color statusColor = Colors.orange;
                          if (status == 'in_progress') statusColor = const Color(0xFFF7C9D1);
                          if (status == 'closed') statusColor = Colors.green;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(Icons.support_agent),
                              title: Text(subject),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text(status.toUpperCase().replaceAll('_', ' '), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
