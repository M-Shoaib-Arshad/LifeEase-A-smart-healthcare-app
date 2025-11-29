class User {
  final String id;
  final String role; // 'patient', 'doctor', 'admin'
  final String email;
  final String name;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? address;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.role,
    required this.email,
    required this.name,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.latitude,
    this.longitude,
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
      'latitude': latitude,
      'longitude': longitude,
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
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  // CopyWith method for easy updates
  User copyWith({
    String? id,
    String? role,
    String? email,
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}