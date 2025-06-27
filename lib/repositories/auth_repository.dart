// repositories/auth_repository.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/APIService.dart';
import '../models/user_model.dart';

class AuthRepository {
  final APIService _apiService;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiService, this._storage);

  Future<User> login(String email, String password) async {
    return await _apiService.login(email, password);
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: 'auth_token');
    final expiry = await _storage.read(key: 'auth_token_expiry');

    if (token == null || expiry == null) return null;

    // Cek expiry lokal
    if (DateTime.parse(expiry).isBefore(DateTime.now())) {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'auth_token_expiry');
      return null;
    }
    return token;
  }

  Future<void> saveToken(String token, DateTime expiry) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(
      key: 'auth_token_expiry',
      value: expiry.toIso8601String(),
    );
  }
}
