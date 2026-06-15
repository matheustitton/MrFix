import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../domain/entities/entities.dart';
import '../../core/constants/app_constants.dart';

/// Provider de solicitações de serviço.
/// Implementa polling assíncrono: a cada [AppConstants.pollingInterval]
/// busca o status atualizado das solicitações ativas do backend.
/// Isso garante que o app do cliente reflita mudanças feitas pelo
/// prestador (aceite, início, conclusão) sem ação manual.
/// Sprint 4: o polling será substituído por WebSocket ou Firebase FCM.
class ServiceRequestProvider extends ChangeNotifier {
  final RemoteDataSource _dataSource;

  List<ServiceRequestEntity> _requests = [];
  ServiceRequestEntity? _selected;
  List<ServiceCategoryEntity> _categories = [];
  bool _loading = false;
  bool _creating = false;
  String? _error;
  Timer? _pollingTimer;

  ServiceRequestProvider(this._dataSource);

  List<ServiceRequestEntity> get requests => _requests;
  ServiceRequestEntity? get selected => _selected;
  List<ServiceCategoryEntity> get categories => _categories;
  bool get loading => _loading;
  bool get creating => _creating;
  String? get error => _error;

  // ── Polling ───────────────────────────────────────────────────────────────

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(AppConstants.pollingInterval, (_) {
      _silentRefresh();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _silentRefresh() async {
    try {
      final updated = await _dataSource.getMyRequests();
      _requests = updated;

      if (_selected != null) {
        final updatedSelected = updated.where((r) => r.id == _selected!.id);
        if (updatedSelected.isNotEmpty) {
          _selected = updatedSelected.first;
        }
      }
      notifyListeners();
    } catch (_) {
      // Falha silenciosa...
    }
  }

  // ── Data Loading ──────────────────────────────────────────────────────────

  Future<void> loadCategories() async {
    try {
      _categories = await _dataSource.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadRequests() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _requests = await _dataSource.getMyRequests();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadRequest(String id) async {
    _loading = true;
    notifyListeners();
    try {
      _selected = await _dataSource.getRequest(id);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<ServiceRequestEntity?> createRequest({
    required String categoryId,
    required String title,
    required String address,
    String? description,
    String preferredGender = 'any',
    String? scheduledAt,
  }) async {
    _creating = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _dataSource.createRequest(
        categoryId: categoryId,
        title: title,
        address: address,
        description: description,
        preferredGender: preferredGender,
        scheduledAt: scheduledAt,
      );
      _requests = [created, ..._requests];
      _creating = false;
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      _creating = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelRequest(String id, {String? reason}) async {
    try {
      final updated = await _dataSource.updateStatus(
        id, 'cancelled', cancellationReason: reason,
      );
      _updateRequest(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitRating({
    required String requestId,
    required int score,
    String? comment,
  }) async {
    try {
      await _dataSource.submitRating(
        serviceRequestId: requestId,
        score: score,
        comment: comment,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateRequest(ServiceRequestEntity updated) {
    _requests = _requests.map((r) => r.id == updated.id ? updated : r).toList();
    if (_selected?.id == updated.id) _selected = updated;
    notifyListeners();
  }

  void selectRequest(ServiceRequestEntity request) {
    _selected = request;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
