class SupportTicketModel {
  final String id;
  final String userEmail;
  final String subject;
  final String message;
  final String status; // "open", "in-progress", "closed"
  final DateTime createdAt;

  SupportTicketModel({
    required this.id,
    required this.userEmail,
    required this.subject,
    required this.message,
    this.status = 'open',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SupportTicketModel.fromMap(Map<String, dynamic> map) {
    return SupportTicketModel(
      id: map['id'] ?? '',
      userEmail: map['userEmail'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'open',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
