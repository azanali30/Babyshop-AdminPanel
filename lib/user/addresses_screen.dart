import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  Future<String?> _safeEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email?.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Addresses', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressSheet(context, service),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<String?>(
        future: _safeEmail(),
        builder: (context, emailSnap) {
          final safeEmail = emailSnap.data;
          if (safeEmail == null) {
            return const Center(child: Text('Please login to manage addresses'));
          }
          return StreamBuilder<QuerySnapshot>(
            stream: service.getAddresses(safeEmail),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('No saved addresses', style: TextStyle(color: Colors.grey[600])),
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final line1 = (data['line1'] ?? '').toString();
                  final line2 = (data['line2'] ?? '').toString();
                  final city = (data['city'] ?? '').toString();
                  final phone = (data['phone'] ?? '').toString();
                  final isDefault = (data['isDefault'] ?? false) as bool;
                  final formatted = [line1, if (line2.isNotEmpty) line2, city].join(', ');
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
                              Text(formatted, style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600)),
                              if (isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: Text('Default', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Phone: $phone', style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await service.setDefaultAddress(doc.id);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Default address updated')));
                                },
                                child: const Text('Set Default'),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection('users').doc(safeEmail).collection('addresses').doc(doc.id).delete();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

void _showAddAddressSheet(BuildContext context, FirestoreService service) {
  final line1 = TextEditingController();
  final line2 = TextEditingController();
  final city = TextEditingController();
  final phone = TextEditingController();
  bool makeDefault = true;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Address', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TextField(
                  controller: line1,
                  decoration: const InputDecoration(labelText: 'Address Line 1', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: line2,
                  decoration: const InputDecoration(labelText: 'Address Line 2', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: city,
                  decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Make default'),
                    StatefulBuilder(
                      builder: (context, setState) => Switch(
                        value: makeDefault,
                        onChanged: (v) {
                          setState(() => makeDefault = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await service.addAddress(
                        line1: line1.text.trim(),
                        line2: line2.text.trim(),
                        city: city.text.trim(),
                        phone: phone.text.trim(),
                        isDefault: makeDefault,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address saved')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Address', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
