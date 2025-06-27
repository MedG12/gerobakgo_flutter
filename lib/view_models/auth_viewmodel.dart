// view_models/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepo;

  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;
  String? _token;

  AuthViewModel(this._authRepo) {
    // Inisialisasi token jika ada
    _authRepo.getToken().then((token) {
      if (token != null) {
        _token = token;
        notifyListeners();
      }
    });
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await _authRepo.login(email, password);
      _saveToken(_currentUser!.token!);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Simpan token di saved storage
  Future<void> _saveToken(String token) async {
    _authRepo.saveToken(token, DateTime.now().add(Duration(days: 30)));
    _token = token;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
