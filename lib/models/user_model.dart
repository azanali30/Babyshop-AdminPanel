class UserModel {
  final String name;
  final String email;
  final String role; // "user" or "admin"
  final String? address;
  final String? phone;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    this.address,
    this.phone,
  });

  // Convert Firestore map → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      email: map['email'],
      role: map['role'],
      address: map['address'],
      phone: map['phone'],
    );
  }

  // Convert UserModel → Map<String, dynamic> for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'address': address,
      'phone': phone,
    };
  }
}
