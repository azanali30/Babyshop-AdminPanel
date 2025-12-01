import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firestore_service.dart';
import 'orders_screen.dart';
import 'addresses_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<String?> _safeEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email?.replaceAll('.', ',');
  }

  Stream<QuerySnapshot> _cartStream(String safeEmail) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(safeEmail)
        .collection('cart')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            Text('My Cart', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
      ),
      body: FutureBuilder<String?>(
        future: _safeEmail(),
        builder: (context, emailSnap) {
          final safeEmail = emailSnap.data;
          if (safeEmail == null) {
            return const Center(child: Text('Please login to view your cart'));
          }
          return StreamBuilder<QuerySnapshot>(
            stream: _cartStream(safeEmail),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('Your cart is empty',
                      style: TextStyle(color: Colors.grey[600])),
                );
              }
              final docs = snapshot.data!.docs;
              num total = 0;
              for (final d in docs) {
                final data = d.data() as Map<String, dynamic>;
                total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] ?? '').toString();
                        final image = (data['image'] ?? '').toString();
                        final price = (data['price'] ?? 0);
                        final qty = (data['quantity'] ?? 1);
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: image.isNotEmpty
                                          ? Image.network(image,
                                              fit: BoxFit.cover)
                                          : Icon(Icons.image,
                                              color: Colors.grey[400]),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(name,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(safeEmail)
                                            .collection('cart')
                                            .doc(doc.id)
                                            .delete();
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('PKR $price',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF773D44))),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          onPressed: () async {
                                            final newQty =
                                                (qty as num).toInt() - 1;
                                            if (newQty < 1) return;
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(safeEmail)
                                                .collection('cart')
                                                .doc(doc.id)
                                                .update({'quantity': newQty});
                                          },
                                        ),
                                        Text('$qty',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          onPressed: () async {
                                            final newQty =
                                                (qty as num).toInt() + 1;
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(safeEmail)
                                                .collection('cart')
                                                .doc(doc.id)
                                                .update({'quantity': newQty});
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Size',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            fontWeight: FontWeight.w600)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Text(((data['size'] ?? '')
                                              .toString()
                                              .isNotEmpty
                                          ? (data['size'] ?? '').toString()
                                          : '-')),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontWeight: FontWeight.bold)),
                            Text('PKR $total',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF773D44))),
                          ],
                        ),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              _showCheckoutSheet(
                                  context, safeEmail, docs, total);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: const Text('Checkout',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

void _showCheckoutSheet(BuildContext context, String safeEmail,
    List<QueryDocumentSnapshot> docs, num total) {
  final addressController = TextEditingController();
  String payment = 'Cash on Delivery';

  // Prefill default address
  (() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final safeEmail = user.email!.replaceAll('.', ',');
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(safeEmail)
          .collection('addresses');
      final snap = await col.where('isDefault', isEqualTo: true).limit(1).get();
      if (snap.docs.isNotEmpty) {
        final d = snap.docs.first.data();
        final formatted =
            '${d['line1']}${(d['line2'] ?? '').toString().isNotEmpty ? ', ' + d['line2'] : ''}, ${d['city']}';
        addressController.text = formatted;
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(safeEmail)
            .get();
        final udata = userDoc.data();
        if (udata != null && (udata['address'] ?? '').toString().isNotEmpty) {
          addressController.text = (udata['address'] as String);
        }
      }
    }
  })();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checkout',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Method'),
                    DropdownButton<String>(
                      value: payment,
                      items: const [
                        DropdownMenuItem(
                            value: 'Cash on Delivery',
                            child: Text('Cash on Delivery')),
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                      ],
                      onChanged: (v) {
                        if (v != null) payment = v;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddressesScreen()));
                    },
                    child: Text('Manage Addresses',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final items = docs.map((d) {
                        final m = d.data() as Map<String, dynamic>;
                        return {
                          'productId': m['productId'],
                          'name': m['name'],
                          'price': m['price'],
                          'quantity': m['quantity'],
                          'size': m['size'],
                          'image': m['image'],
                        };
                      }).toList();
                      final service = FirestoreService();
                      await service.placeOrder(
                          items: items,
                          total: total,
                          address: addressController.text.trim(),
                          paymentMethod: payment);
                      for (final d in docs) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(safeEmail)
                            .collection('cart')
                            .doc(d.id)
                            .delete();
                      }
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrdersScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Place Order',
                        style: TextStyle(color: Colors.white)),
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
