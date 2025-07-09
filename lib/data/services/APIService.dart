import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:gerobakgo_with_api/data/models/menu_model.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/models/user_model.dart';
import 'package:dio/dio.dart';

class APIService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Helper method untuk request dengan token
  Future<Response> _requestWithToken({
    required String method,
    required String endpoint,
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final uri = "$_baseUrl$endpoint";
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final options = Options(headers: headers);
    switch (method) {
      case 'GET':
        return await dio.get(uri, options: options);
      case 'POST':
        return await dio.post(uri, options: options, data: body);
      case 'PUT':
        return await dio.put(uri, options: options, data: body);
      default:
        throw Exception('Unsupported HTTP method');
    }
  }

  // Login
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        'user/login',
        data: {'email': email, 'password': password},
      );
      switch (response.statusCode) {
        case 200:
          // Tambahkan pengecekan untuk response success false
          if (response.data['success'] == false) {
            throw Exception(response.data['message'] ?? 'Unauthorized');
          }
          return User.fromMap(response.data);
        case 401:
          throw Exception('Unauthorized');
        case 422:
          throw Exception(response.data['message']);
        default:
          throw Exception('Failed to login');
      }
    } on DioException catch (e) {
      // Tangani error dari Dio
      if (e.response != null) {
        // Jika server mengembalikan response error
        final errorData = e.response?.data;

        if (errorData is Map<String, dynamic>) {
          // Tangani error validasi
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            final errorMessages = errors.values
                .expand((messages) => (messages as List).cast<String>())
                .join('\n');
            throw AuthException(errorData['message'] ?? errorMessages);
          }
          // Tangani error unauthorized
          else if (errorData.containsKey('message')) {
            throw AuthException(errorData['message']);
          }
        }
      }
      throw Exception(e.message ?? 'An error occurred during login');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Logout
  Future<void> logout(String token) async {
    _requestWithToken(method: 'POST', endpoint: 'user/logout', token: token);
  }

  Future<String> uploadImage(File imagePath, int id, String token) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath.path),
    });
    try {
      final response = await dio.post(
        'user/upload/$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
        data: formData,
      );
      return response.data['data'];
    } on DioException catch (e) {
      // Tangani error dari Dio
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          throw AuthException(errorData['message']);
        }
      }
      throw Exception(e.message ?? 'An error occurred during image upload');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Register
  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await dio.post(
        'user/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      switch (response.statusCode) {
        case 201:
          return User.fromMap(response.data);
        case 422:
          throw Exception(response.data['message']);
        default:
          throw Exception('Failed to register');
      }
    } on DioException catch (e) {
      // Tangani error dari Dio
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          throw AuthException(errorData['message']);
        }
      }
      throw Exception(e.message ?? 'An error occurred during registration');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Merchant>> getMerchants(String token) async {
    final response = await _requestWithToken(
      method: 'GET',
      token: token,
      endpoint: 'merchant',
    );
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((merchant) => Merchant.fromJson(merchant)).toList();
    } else {
      throw Exception('Failed to load merchants');
    }
  }

  Future<Merchant> getMerchantById(int id, String token) async {
    try {
      final response = await _requestWithToken(
        method: 'GET',
        token: token,
        endpoint: 'merchant/detail/$id',
      );
      if (response.statusCode == 200) {
        return Merchant.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load merchant');
      }
    } on DioException catch (e) {
      // Tangani error dari Dio
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          throw AuthException(errorData['message']);
        }
        throw Exception(e.message ?? 'An error occurred during merchant load');
      }
      throw Exception(e.message ?? 'An error occurred during merchant load');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<User> updateUser(int id, String name, String token) async {
    try {
      final response = await _requestWithToken(
        method: 'PUT',
        token: token,
        endpoint: 'user/update/${id}',
        body: {'name': name},
      );
      switch (response.statusCode) {
        case 200:
          return User.fromMap(response.data);
        case 422:
          throw Exception(response.data['message']);
        default:
          throw Exception('Failed to update user');
      }
    } on DioException catch (e) {
      // Tangani error dari Dio
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          throw AuthException(errorData['message']);
        }
      }
      throw Exception(e.message ?? 'An error occurred during update user');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> updateLocation(String token, Location location) async {
    try {
      await _requestWithToken(
        method: 'POST',
        endpoint: 'merchant/location/update/${location.id}',
        token: token,
        body: location.toJson(),
      );
    } catch (e) {
      print('error updating user location $e');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
