// lib/core/exceptions/app_exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);
}

class AuthException extends AppException {
  const AuthException([String? message, StackTrace? stackTrace])
    : super(message ?? 'Something went wrong ', stackTrace);
}

// Auth-related
class TokenException extends AppException {
  const TokenException([String? message, StackTrace? stackTrace])
    : super(message ?? 'Token tidak valid', stackTrace);
}

// Merchant-related
class MerchantException extends AppException {
  const MerchantException([String? message, StackTrace? stackTrace])
    : super(message ?? 'Merchant tidak ditemukan', stackTrace);
}

// Network
class NetworkException extends AppException {
  const NetworkException([String? message, StackTrace? stackTrace])
    : super(message ?? 'Gagal terhubung ke server', stackTrace);
}

class FieldException extends AppException {
  final String field;
  const FieldException({
    required this.field,
    String? message,
    StackTrace? stackTrace,
  }) : super(message ?? "$field tidak boleh kosong");
}
