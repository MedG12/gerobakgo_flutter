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
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthViewModel(this._authRepo) {
    init();
  }

  Future<bool> init() async {
    try {
      final token = await _authRepo.getToken();
      if (token != null) {
        _token = token;
        _currentUser = await _authRepo.getCurrentUser();
      }
      _isInitialized = true;
      notifyListeners();
      return true; // Tambahkan return value
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = true; // Tetap set initialized meskipun error
      notifyListeners();
      return false;
    }
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

      // Simpan data user ke shared preferences
      _authRepo.saveUser(_currentUser!);
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
    _authRepo.saveToken(token, DateTime.now().add(Duration(minutes: 30)));
    _token = token;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
