class User {
  final String id;
  final String role; // 'patient', 'doctor', 'admin'
  final String email;
  final String name;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? address;

  User({
    required this.id,
    required this.role,
    required this.email,
    required this.name,
    this.phone,
    this.dateOfBirth,
    this.address,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'email': email,
      'name': name,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
    };
  }

  // Create from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      role: map['role'] ?? 'patient',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      address: map['address'],
    );
  }
}