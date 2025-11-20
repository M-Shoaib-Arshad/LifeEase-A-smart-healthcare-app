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

    await doc.update(updates);
  }
}