import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../domain/entities/entities.dart';
import '../../core/constants/app_constants.dart';

class ServiceRequestProvider extends ChangeNotifier {
  final RemoteDataSource _dataSource;

  // ── Estado ────────────────────────────────────────────────────────────────
  List<ServiceRequestEntity> _availableRequests = [];
  List<ServiceRequestEntity> _myRequests = [];
  List<ProviderSpecialtyEntity> _mySpecialties = [];
  List<ServiceCategoryEntity> _categories = [];
  ServiceRequestEntity? _selected;

  bool _loading = false;
  bool _actionLoading = false;
  bool _creating = false;
  String? _error;
  Timer? _pollingTimer;
  int _newRequestCount = 0;

  ServiceRequestProvider(this._dataSource);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<ServiceRequestEntity> get availableRequests => _availableRequests;
  List<ServiceRequestEntity> get myRequests        => _myRequests;
  List<ProviderSpecialtyEntity> get mySpecialties  => _mySpecialties;
  List<ServiceCategoryEntity> get categories       => _categories;
  ServiceRequestEntity? get selected               => _selected;
  bool get loading                                 => _loading;
  bool get actionLoading                           => _actionLoading;
  bool get creating                                => _creating;
  String? get error                                => _error;
  int get newRequestCount                          => _newRequestCount;

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
      final available = await _dataSource.getAvailableRequests();
      final myReqs    = await _dataSource.getMyRequests();

      final oldIds = _availableRequests.map((r) => r.id).toSet();
      _newRequestCount = available.where((r) => !oldIds.contains(r.id)).length;

      _availableRequests = available;
      _myRequests        = myReqs;

      if (_selected != null) {
        final match = myReqs.where((r) => r.id == _selected!.id);
        if (match.isNotEmpty) _selected = match.first;
      }

      notifyListeners();
    } catch (_) {
      // Falha silenciosa
    }
  }

  // ── Carregamento ──────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _dataSource.getAvailableRequests(),
        _dataSource.getMyRequests(),
      ]);
      _availableRequests = results[0] as List<ServiceRequestEntity>;
      _myRequests        = results[1] as List<ServiceRequestEntity>;
      _newRequestCount   = 0;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _dataSource.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMySpecialties() async {
    try {
      _mySpecialties = await _dataSource.getMySpecialties();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
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

  // ── Ações de solicitação ──────────────────────────────────────────────────

  Future<bool> acceptRequest(String id) async {
    _actionLoading = true;
    notifyListeners();
    try {
      final updated = await _dataSource.updateStatus(id, 'accepted');
      _availableRequests.removeWhere((r) => r.id == id);
      _myRequests = [updated, ..._myRequests];
      if (_selected?.id == id) _selected = updated;
      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectRequest(String id) async {
    _actionLoading = true;
    notifyListeners();
    try {
      await _dataSource.updateStatus(id, 'cancelled');
      _availableRequests.removeWhere((r) => r.id == id);
      if (_selected?.id == id) _selected = null;
      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> startService(String id) async {
    _actionLoading = true;
    notifyListeners();
    try {
      final updated = await _dataSource.updateStatus(id, 'in_progress');
      _updateInList(updated);
      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeService(String id) async {
    _actionLoading = true;
    notifyListeners();
    try {
      final updated = await _dataSource.updateStatus(id, 'completed');
      _updateInList(updated);
      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSpecialty({
    required String categoryId,
    double? averagePrice,
    int? experienceYears,
    String? bio,
  }) async {
    try {
      final specialty = await _dataSource.addSpecialty(
        categoryId:      categoryId,
        averagePrice:    averagePrice,
        experienceYears: experienceYears,
        bio:             bio,
      );
      _mySpecialties = [specialty, ..._mySpecialties];
      notifyListeners();
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _updateInList(ServiceRequestEntity updated) {
    _myRequests = _myRequests
        .map((r) => r.id == updated.id ? updated : r)
        .toList();
    if (_selected?.id == updated.id) _selected = updated;
  }

  void clearBadge() {
    if (_newRequestCount == 0) return;
    _newRequestCount = 0;
    notifyListeners();
  }

  void selectRequest(ServiceRequestEntity request) {
    _selected = request;
    _newRequestCount = 0;
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