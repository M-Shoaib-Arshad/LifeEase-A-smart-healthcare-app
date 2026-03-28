class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship; // 'spouse', 'parent', 'sibling', 'friend', 'other'

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };

  factory EmergencyContact.fromMap(Map<String, dynamic> m) => EmergencyContact(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        phone: m['phone'] ?? '',
        relationship: m['relationship'] ?? 'other',
      );
}
