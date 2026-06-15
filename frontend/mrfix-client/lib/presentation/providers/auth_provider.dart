import 'package:flutter/foundation.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/entities.dart';
import '../../data/models/models.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final RemoteDataSource _dataSource;

  AuthStatus _status = AuthStatus.unknown;
  UserEntity? _user;
  String? _error;
  bool _loading = false;

  AuthProvider(this._dataSource);

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  //──────────── Verificação token salvo e carregamento do usuário ───────────────────────────────────────────────
  Future<void> checkAuth() async {
    final token = await ApiClient.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _user = await _dataSource.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await ApiClient.clearToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _dataSource.login(email, password);
      await ApiClient.saveToken(data['token']);
      _user = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _dataSource.register(
        name: name, email: email, password: password, gender: gender,
      );
      await ApiClient.saveToken(data['token']);
      _user = UserModel.fromJson(data['user']);
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
