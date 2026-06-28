import '../models/models.dart';
import '../../core/network/api_client.dart';

/// DataSource remoto — única camada que faz chamadas HTTP.
/// Encapsula todos os endpoints da API MisterFix.
class RemoteDataSource {

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiClient.post(
      '/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );
    return ApiClient.parseResponse(res);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    final res = await ApiClient.post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
        'role': 'client',
        'gender': gender,
      },
      auth: false,
    );
    return ApiClient.parseResponse(res);
  }

  Future<UserModel> getMe() async {
    final res = await ApiClient.get('/auth/me');
    final data = ApiClient.parseResponse(res);
    return UserModel.fromJson(data['user']);
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<List<ServiceCategoryModel>> getCategories() async {
    final res = await ApiClient.get('/categories', auth: false);
    final data = ApiClient.parseResponse(res);
    return (data['data'] as List)
        .map((e) => ServiceCategoryModel.fromJson(e))
        .toList();
  }

  // ── Providers ─────────────────────────────────────────────────────────────

  Future<List<UserModel>> getProviders({String? gender, String? categoryId}) async {
    final params = <String>[];
    if (gender != null && gender != 'any') params.add('gender=$gender');
    if (categoryId != null) params.add('category_id=$categoryId');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final res = await ApiClient.get('/providers$query', auth: false);
    final data = ApiClient.parseResponse(res);
    return (data['data'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  // ── Service Requests ──────────────────────────────────────────────────────

  Future<List<ServiceRequestModel>> getMyRequests({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final res = await ApiClient.get('/service-requests$query');
    final data = ApiClient.parseResponse(res);
    return (data['data'] as List)
        .map((e) => ServiceRequestModel.fromJson(e))
        .toList();
  }

  Future<ServiceRequestModel> getRequest(String id) async {
    final res = await ApiClient.get('/service-requests/$id');
    final data = ApiClient.parseResponse(res);
    return ServiceRequestModel.fromJson(data['data']);
  }

  Future<ServiceRequestModel> createRequest({
    required String categoryId,
    required String title,
    required String address,
    String? description,
    String preferredGender = 'any',
    String? scheduledAt,
  }) async {
    final body = <String, dynamic>{
      'category_id': categoryId,
      'title': title,
      'address': address,
      'preferred_gender': preferredGender,
      if (description != null) 'description': description,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
    };
    final res = await ApiClient.post('/service-requests', body);
    final data = ApiClient.parseResponse(res);
    return ServiceRequestModel.fromJson(data['data']);
  }

  Future<ServiceRequestModel> updateStatus(
    String id,
    String status, {
    String? cancellationReason,
  }) async {
    final body = <String, dynamic>{
      'status': status,
      if (cancellationReason != null) 'cancellation_reason': cancellationReason,
    };
    final res = await ApiClient.patch('/service-requests/$id/status', body);
    final data = ApiClient.parseResponse(res);
    return ServiceRequestModel.fromJson(data['data']);
  }

  // ── Ratings ───────────────────────────────────────────────────────────────

  Future<void> submitRating({
    required String serviceRequestId,
    required int score,
    String? comment,
  }) async {
    final res = await ApiClient.post('/ratings', {
      'service_request_id': serviceRequestId,
      'score': score,
      if (comment != null) 'comment': comment,
    });
    ApiClient.parseResponse(res);
  }
  // ── Notifications ─────────────────────────────────────────────────────────

  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final res = await ApiClient.get('/notifications');
      final data = ApiClient.parseResponse(res);
      return (data['data'] as List)
          .map((e) => AppNotificationModel.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await ApiClient.patch('/notifications/$id/read', {});
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await ApiClient.patch('/notifications/read-all', {});
    } catch (_) {}
  }
}
