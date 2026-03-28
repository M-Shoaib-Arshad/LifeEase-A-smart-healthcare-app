import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;

class UserService {
  final _db = FirebaseFirestore.instance;
  static const String usersCollection = 'users';

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required String role, // 'patient' | 'doctor' | 'admin'
    String? photoURL,
    String? phone,
  }) async {
    final doc = _db.collection(usersCollection).doc(uid);
    final user = model.User(
      id: uid,
      email: email,
      name: name,
      role: role,
      phone: phone,
      address: null,
      dateOfBirth: null,
    );
    await doc.set({
      ...user.toMap(),
      'photoURL': photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<model.User?> getUserProfile(String uid) async {
    final doc = await _db.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return model.User.fromMap(data);
  }

  Stream<model.User?> watchUserProfile(String uid) {
    return _db.collection(usersCollection).doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return model.User.fromMap(snap.data()!);
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    String? address,
    String? photoURL,
    double? latitude,
    double? longitude,
  }) async {
    final doc = _db.collection(usersCollection).doc(uid);
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth.toIso8601String();
    if (address != null) updates['address'] = address;
    if (photoURL != null) updates['photoURL'] = photoURL;
    if (latitude != null) updates['latitude'] = latitude;
    if (longitude != null) updates['longitude'] = longitude;

    await doc.update(updates);
  }

  /// Fetch all users with role == 'doctor' from Firestore.
  /// Only returns doctors that have [latitude] and [longitude] set.
  Future<List<model.User>> getDoctors() async {
    final snapshot = await _db
        .collection(usersCollection)
        .where('role', isEqualTo: 'doctor')
        .get();
    return snapshot.docs
        .map((doc) => model.User.fromMap(doc.data()))
        .where((u) => u.latitude != null && u.longitude != null)
        .toList();
  }
}