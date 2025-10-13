import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  final _syncController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStream => _syncController.stream;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> initialize() async {
    // Load last sync time
    final prefs = await SharedPreferences.getInstance();
    final lastSyncTimestamp = prefs.getInt('last_sync_time');
    if (lastSyncTimestamp != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
    }

    // Monitor connectivity
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOffline = !_isOnline;
        _isOnline = results.any((result) => result != ConnectivityResult.none);

        if (wasOffline && _isOnline) {
          // Connection restored, trigger sync
          _syncController.add(SyncStatus.reconnected);
          syncData();
        } else if (!_isOnline) {
          _syncController.add(SyncStatus.offline);
        }
      },
    );

    // Check initial connectivity
    final results = await Connectivity().checkConnectivity();
    _isOnline = results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> syncData() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      // Simulate sync process
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual sync logic with Firebase
      // 1. Upload local changes
      // 2. Download remote changes
      // 3. Resolve conflicts

      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_sync_time', _lastSyncTime!.millisecondsSinceEpoch);

      _syncController.add(SyncStatus.synced);
    } catch (e) {
      _syncController.add(SyncStatus.error);
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> forceSynccheck() async {
    if (!_isOnline) {
      _syncController.add(SyncStatus.offline);
      return;
    }

    await syncData();
  }

  String getLastSyncText() {
    if (_lastSyncTime == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncController.close();
  }
}

enum SyncStatus {
  syncing,
  synced,
  offline,
  reconnected,
  error,
}
