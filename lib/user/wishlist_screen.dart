import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firestore_service.dart';
import 'cart_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Wishlist', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
      ),
      body: _WishlistBody(),
    );
  }
}

class _WishlistBody extends StatelessWidget {
  const _WishlistBody();

  Future<String?> _safeEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email?.replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _safeEmail(),
      builder: (context, emailSnap) {
        final safeEmail = emailSnap.data;
        if (safeEmail == null) {
          return const Center(child: Text('Please login to view your wishlist'));
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(safeEmail)
              .collection('wishlist')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('Your wishlist is empty', style: TextStyle(color: Colors.grey[600])),
              );
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString();
                final image = (data['image'] ?? '').toString();
                final price = (data['price'] ?? 0);
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: image.isNotEmpty
                              ? Image.network(image, fit: BoxFit.cover)
                              : Icon(Icons.image, color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.w600)),
                              Text('PKR $price'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(safeEmail)
                                .collection('wishlist')
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () async {
                              final service = FirestoreService();
                              final pid = (data['productId'] ?? doc.id).toString();
                              await service.addToCart(productId: pid, name: name, price: price, image: image);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                          ),
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
    );
  }
}
