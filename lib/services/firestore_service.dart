import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Users ----------------
  Future<void> addUser(String name, String email, String address, String phone, String role) async {
    try {
      String safeEmail = email.replaceAll('.', ',');
      await _db.collection('users').doc(safeEmail).set({
        'name': name,
        'email': email,
        'address': address,
        'phone': phone,
        'role': role,
      });
    } catch (e) {
      print("Failed to add user: $e");
      throw e;
    }
  }

  Stream<QuerySnapshot> getUsers() => _db.collection('users').snapshots();

  // ---------------- Products ----------------
  Future<void> addProduct(String id, String name, double price, String image,
      String category, int stock) async {
    await _db.collection('products').doc(id).set({
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getProducts() => _db.collection('products').snapshots();

  Stream<QuerySnapshot> getProductsByCategory(String category) =>
      _db.collection('products').where('category', isEqualTo: category).snapshots();

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.collection('products').doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // ---------------- Categories ----------------
  Stream<QuerySnapshot> getCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .orderBy('title')
        .snapshots();
  }

  Future<void> addCategory(String title, String description, String imageUrl) async {
    await FirebaseFirestore.instance.collection('categories').add({
      'title': title,
      'description': description,
      'image': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory(
      String categoryId, String title, String description, String imageUrl) async {
    await FirebaseFirestore.instance.collection('categories').doc(categoryId).update({
      'title': title,
      'description': description,
      'image': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    await FirebaseFirestore.instance.collection('categories').doc(categoryId).delete();
  }

  // ---------------- Orders ----------------
  Stream<QuerySnapshot> getOrders() => _db.collection('orders').snapshots();

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }

  // ---------------- Reviews ----------------
  Stream<QuerySnapshot> getAllReviews() => _db.collection('reviews').snapshots();

  Future<void> deleteReview(String reviewId) async {
    await _db.collection('reviews').doc(reviewId).delete();
  }

  // ---------------- Support ----------------
  Stream<QuerySnapshot> getAllSupportTickets() => _db.collection('support').snapshots();

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _db.collection('support').doc(ticketId).update({'status': status});
  }

  Future<void> submitSupportTicket({
    required String subject,
    required String description,
    required String type,
  }) async {
    final safeEmail = await _currentSafeEmail();
    final user = FirebaseAuth.instance.currentUser;
    await _db.collection('support').add({
      'subject': subject,
      'description': description,
      'type': type,
      'status': 'open',
      'email': user?.email ?? safeEmail,
      'userId': user?.uid ?? safeEmail,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------- Payments (FIXED) ----------------
  Stream<QuerySnapshot> getPayments() {
    return FirebaseFirestore.instance
        .collection('payments')
        .orderBy('timestamp', descending: true) // FIXED ✔
        .snapshots();
  }

  // ---------------- Cart & Wishlist ----------------
  Future<String?> _currentSafeEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email?.replaceAll('.', ',');
  }

  Future<void> addToCart({
    required String productId,
    required String name,
    required num price,
    required String image,
    String? size,
    int quantity = 1,
  }) async {
    final safeEmail = await _currentSafeEmail();
    if (safeEmail == null) return;
    final user = FirebaseAuth.instance.currentUser;
    await _db
        .collection('users')
        .doc(safeEmail)
        .collection('cart')
        .doc(productId)
        .set({
          'productId': productId,
          'name': name,
          'price': price,
          'image': image,
          'quantity': quantity,
          'size': size ?? '',
          'addedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    await _db.collection('cart').add({
      'productId': productId,
      'userId': user?.uid ?? safeEmail,
      'email': user?.email ?? safeEmail,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleWishlist({
    required String productId,
    required String name,
    required num price,
    required String image,
    required bool add,
  }) async {
    final safeEmail = await _currentSafeEmail();
    if (safeEmail == null) return;
    final user = FirebaseAuth.instance.currentUser;
    final ref = _db
        .collection('users')
        .doc(safeEmail)
        .collection('wishlist')
        .doc(productId);
    if (add) {
      await ref.set({
        'productId': productId,
        'name': name,
        'price': price,
        'image': image,
        'addedAt': FieldValue.serverTimestamp(),
      });
      await _db.collection('wishlist').add({
        'productId': productId,
        'userId': user?.uid ?? safeEmail,
        'email': user?.email ?? safeEmail,
        'date': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  // ---------------- Product Reviews ----------------
  Future<void> addReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final safeEmail = await _currentSafeEmail();
    await _db.collection('reviews').add({
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'user': safeEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _db.collection('products').doc(productId).set({
      'ratingSum': FieldValue.increment(rating),
      'reviews': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }
  
  // ---------------- Addresses ----------------
  Stream<QuerySnapshot> getAddresses(String safeEmail) {
    return _db
        .collection('users')
        .doc(safeEmail)
        .collection('addresses')
        .orderBy('isDefault', descending: true)
        .snapshots();
  }

  Future<void> addAddress({
    required String line1,
    String? line2,
    required String city,
    required String phone,
    bool isDefault = false,
  }) async {
    final safeEmail = await _currentSafeEmail();
    if (safeEmail == null) return;
    final ref = _db.collection('users').doc(safeEmail).collection('addresses').doc();
    await ref.set({
      'line1': line1,
      'line2': line2 ?? '',
      'city': city,
      'phone': phone,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (isDefault) {
      await setDefaultAddress(ref.id);
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final safeEmail = await _currentSafeEmail();
    if (safeEmail == null) return;
    final col = _db.collection('users').doc(safeEmail).collection('addresses');
    final all = await col.get();
    for (final d in all.docs) {
      await col.doc(d.id).update({'isDefault': d.id == addressId});
    }
    final chosen = await col.doc(addressId).get();
    final data = chosen.data();
    if (data != null) {
      final formatted = '${data['line1']}${(data['line2'] ?? '').toString().isNotEmpty ? ', ' + data['line2'] : ''}, ${data['city']}';
      await _db.collection('users').doc(safeEmail).set({'address': formatted, 'phone': data['phone']}, SetOptions(merge: true));
    }
  }
  
  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required num total,
    required String address,
    required String paymentMethod,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final safeEmail = await _currentSafeEmail();
    await _db.collection('orders').add({
      'userId': user?.uid ?? safeEmail,
      'email': user?.email ?? safeEmail,
      'items': items,
      'total': total,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  // ---------------- Dashboard Stats ----------------
  Future<int> getTotalProducts() async {
    return (await _db.collection('products').get()).docs.length;
  }

  Future<int> getTotalOrders() async {
    return (await _db.collection('orders').get()).docs.length;
  }

  Future<int> getTotalUsers() async {
    return (await _db.collection('users').get()).docs.length;
  }

  Future<int> getPendingOrders() async {
    return (await _db.collection('orders')
        .where('status', isEqualTo: 'pending')
        .get()).docs.length;
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    final snapshot = await _db
        .collection('activity')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}

