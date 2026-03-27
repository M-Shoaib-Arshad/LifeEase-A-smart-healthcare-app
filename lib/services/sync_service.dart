import 'package:flutter/foundation.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'api_service.dart';
import '../models/appointment.dart';
import '../models/health_record.dart';

/// Listens for connectivity restoration and flushes the offline write queue.
///
/// Operations are stored in Hive's `sync_queue` box as maps with at least a
/// `type` field (`create_appointment`, `update_appointment`,
/// `delete_appointment`, `create_health_record`, `update_health_record`,
/// `delete_health_record`).
class SyncService {
  final CacheService _cache = CacheService();
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  /// Start listening for connectivity changes; flush the queue whenever the
  /// device comes back online.
  void startListening() {
    _connectivity.onlineStream.listen((online) {
      if (online) {
        _flushQueue();
      }
    });
  }

  /// Process every pending operation from the sync queue in order.
  Future<void> _flushQueue() async {
    final queue = _cache.getQueue();
    if (queue.isEmpty) return;

    final failed = <Map<String, dynamic>>[];

    for (final op in queue) {
      try {
        await _processOperation(op);
      } catch (e) {
        debugPrint('SyncService: failed to process op $op – $e');
        failed.add(op);
      }
    }

    // Replace queue with only the operations that failed so they are retried
    // on the next connectivity event.
    await _cache.clearQueue();
    for (final op in failed) {
      await _cache.enqueueOperation(op);
    }
  }

  Future<void> _processOperation(Map<String, dynamic> op) async {
    final type = op['type'] as String? ?? '';
    switch (type) {
      case 'create_appointment':
        await _api.createAppointment(Appointment.fromMap(_dataMap(op)));
        break;
      case 'update_appointment':
        await _api.updateAppointment(Appointment.fromMap(_dataMap(op)));
        break;
      case 'delete_appointment':
        await _api.deleteAppointment(op['id'] as String);
        break;
      case 'create_health_record':
        await _api.createHealthRecord(HealthRecord.fromMap(_dataMap(op)));
        break;
      case 'update_health_record':
        await _api.updateHealthRecord(HealthRecord.fromMap(_dataMap(op)));
        break;
      case 'delete_health_record':
        await _api.deleteHealthRecord(op['id'] as String);
        break;
      default:
        debugPrint('SyncService: unknown operation type "$type"');
    }
  }

  /// Safely extracts and casts the `data` payload from a queue operation map.
  Map<String, dynamic> _dataMap(Map<String, dynamic> op) =>
      Map<String, dynamic>.from(op['data'] as Map);
}
