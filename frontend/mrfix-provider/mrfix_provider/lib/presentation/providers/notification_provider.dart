import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/models/models.dart';
import '../../domain/entities/entities.dart';
import '../../core/constants/app_constants.dart';

class NotificationProvider extends ChangeNotifier {
  final RemoteDataSource _dataSource;

  List<AppNotificationEntity> _notifications = [];
  bool _panelOpen = false;
  Timer? _pollingTimer;

  NotificationProvider(this._dataSource);

  List<AppNotificationEntity> get notifications => _notifications;
  bool get panelOpen => _panelOpen;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  void startPolling() {
    _pollingTimer?.cancel();
    load();
    _pollingTimer = Timer.periodic(AppConstants.pollingInterval, (_) => load());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> load() async {
    final list = await _dataSource.getNotifications();
    _notifications = list;
    notifyListeners();
  }

  void togglePanel() {
    _panelOpen = !_panelOpen;
    notifyListeners();
  }

  void closePanel() {
    _panelOpen = false;
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    await _dataSource.markNotificationRead(id);
    _notifications = _notifications.map((n) => n.id == id
        ? AppNotificationModel.fromJson({
            'id': n.id, 'title': n.title, 'body': n.body,
            'type': n.type, 'request_id': n.requestId,
            'read': true,
            'created_at': n.createdAt.toIso8601String(),
          })
        : n).toList();
    notifyListeners();
  }

  Future<void> markAllRead() async {
    await _dataSource.markAllNotificationsRead();
    _notifications = _notifications.map((n) =>
      AppNotificationModel.fromJson({
        'id': n.id, 'title': n.title, 'body': n.body,
        'type': n.type, 'request_id': n.requestId,
        'read': true,
        'created_at': n.createdAt.toIso8601String(),
      })
    ).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}