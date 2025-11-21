import 'package:cloud_firestore/cloud_firestore.dart';

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
    throw e; // optional rethrow for caller
  }
}


  Stream<QuerySnapshot> getUsers() => _db.collection('users').snapshots();

  Stream<DocumentSnapshot> getUser(String email) =>
      _db.collection('users').doc(email).snapshots();

  Future<DocumentSnapshot> getUserOnce(String email) async {
    return await _db.collection('users').doc(email).get();
  }

  // ---------------- Products ----------------
  Future<void> addProduct(String id, String name, double price, String image,
      String category, int stock) async {
    await _db.collection('products').doc(id).set({
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock,
    });
  }

  Stream<QuerySnapshot> getProducts() => _db.collection('products').snapshots();

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _db.collection('products').doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  // ---------------- Orders ----------------
  Stream<QuerySnapshot> getOrders() => _db.collection('orders').snapshots();

Future<void> updateOrderStatus(String orderId, String status) async {
  final doc = _db.collection('orders').doc(orderId);
  final snapshot = await doc.get();
  if (snapshot.exists) {
    await doc.update({'status': status});
  } else {
    print("Order $orderId not found");
  }
}


  // ---------------- Reviews ----------------
  Stream<QuerySnapshot> getAllReviews() => _db.collection('reviews').snapshots();

  Future<void> deleteReview(String reviewId) async {
    await _db.collection('reviews').doc(reviewId).delete();
  }

  // ---------------- Support ----------------
  Stream<QuerySnapshot> getAllSupportTickets() =>
      _db.collection('support').snapshots();

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _db.collection('support').doc(ticketId).update({'status': status});
  }
}
