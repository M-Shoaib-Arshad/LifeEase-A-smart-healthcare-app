import 'package:hive/hive.dart';

/// Hive-backed local cache for offline support.
///
/// All Hive boxes must be opened before use – call [initBoxes] during app
/// start (or ensure [main.dart] opens them via `Hive.openBox`).
class CacheService {
  static const _appointments = 'appointments';
  static const _healthRecords = 'health_records';
  static const _userProfile = 'user_profile';
  static const _syncQueue = 'sync_queue';

  // ---------------------------------------------------------------------------
  // Appointments
  // ---------------------------------------------------------------------------

  Future<void> cacheAppointments(
      List<Map<String, dynamic>> appointments) async {
    final box = Hive.box(_appointments);
    await box.put('list', appointments);
  }

  List<Map<String, dynamic>> getCachedAppointments() {
    final box = Hive.box(_appointments);
    final raw = box.get('list');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  // ---------------------------------------------------------------------------
  // Health Records
  // ---------------------------------------------------------------------------

  Future<void> cacheHealthRecords(
      List<Map<String, dynamic>> records) async {
    final box = Hive.box(_healthRecords);
    await box.put('list', records);
  }

  List<Map<String, dynamic>> getCachedHealthRecords() {
    final box = Hive.box(_healthRecords);
    final raw = box.get('list');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------

  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    final box = Hive.box(_userProfile);
    await box.put('data', profile);
  }

  Map<String, dynamic>? getCachedUserProfile() {
    final box = Hive.box(_userProfile);
    final raw = box.get('data');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  // ---------------------------------------------------------------------------
  // Sync Queue  (pending writes while offline)
  // ---------------------------------------------------------------------------

  Future<void> enqueueOperation(Map<String, dynamic> operation) async {
    final box = Hive.box(_syncQueue);
    final List<Map<String, dynamic>> queue = getQueue();
    queue.add(operation);
    await box.put('queue', queue);
  }

  List<Map<String, dynamic>> getQueue() {
    final box = Hive.box(_syncQueue);
    final raw = box.get('queue');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
      (raw as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  Future<void> clearQueue() async {
    await Hive.box(_syncQueue).put('queue', <Map<String, dynamic>>[]);
  }

  // ---------------------------------------------------------------------------
  // Full clear (call on logout)
  // ---------------------------------------------------------------------------

  Future<void> clearAll() async {
    for (final name in [
      _appointments,
      _healthRecords,
      _userProfile,
      _syncQueue,
    ]) {
      await Hive.box(name).clear();
    }
  }
}
