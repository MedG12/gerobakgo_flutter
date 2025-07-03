// repositories/auth_repository.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/APIService.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final APIService _apiService;
  final FlutterSecureStorage _storage;

  AuthRepository(this._apiService, this._storage);

  Future<User> login(String email, String password) async {
    return await _apiService.login(email, password);
  }

  Future<void> logout(String token) async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'auth_token_expiry');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await _apiService.logout(token);
  }

  Future<User> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    return await _apiService.register(name, email, password, role);
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

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user')) await prefs.remove('user');
    await prefs.setString(
      'user',
      jsonEncode(user.toJson()),
    ); // Objek → JSON → String
  }

  Future<User> updateUser(int id, String name, String token) async {
    return _apiService.updateUser(id, name, token);
  }

  Future<String> uploadImage(File image, int id, String token) async {
    return _apiService.uploadImage(image, id, token);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user'); // Ambil JSON string
    try {
      final userMap =
          jsonDecode(userJson!) as Map<String, dynamic>; // String → Map

      return User.fromMap(userMap); // Map → Objek User
    } catch (e) {
      print('Error parsing user data: $e');
      return null; // Kembalikan null jika parsing gagal
    }
  }
}
