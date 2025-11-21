class ReviewModel {
  final String id;
  final String userEmail;
  final String productId;
  final String comment;
  final int rating; // 1-5
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userEmail,
    required this.productId,
    required this.comment,
    required this.rating,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      userEmail: map['userEmail'] ?? '',
      productId: map['productId'] ?? '',
      comment: map['comment'] ?? '',
      rating: map['rating'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'productId': productId,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}
