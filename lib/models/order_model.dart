class OrderModel {
  final String id;
  final String userEmail;
  final List<Map<String, dynamic>> products; // List of product IDs & quantity
  final double totalPrice;
  final String status; // "pending", "shipped", "delivered"
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userEmail,
    required this.products,
    required this.totalPrice,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userEmail: map['userEmail'] ?? '',
      products: List<Map<String, dynamic>>.from(map['products'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'products': products,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
