// view_models/auth_viewmodel.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class AuthViewmodel with ChangeNotifier {
  final AuthRepository _authRepo;
  final MerchantRepository _merchantRepo;

  User? _currentUser;
  Merchant? _currentMerchant;
  String? _errorMessage;
  bool _isLoading = false;
  String? _token;
  bool _isInitialized = false;

  AuthViewmodel(this._authRepo, this._merchantRepo) {
    init();
  }

  set setLoading(bool status) {
    _isLoading = status;
    notifyListeners();
  }

  set user(User user) {
    _currentUser = user;
    _authRepo.saveUser(user);
    notifyListeners();
  }

  Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      final token = await _authRepo.getToken();
      if (token != null) {
        _token = token;
        _currentUser = await _authRepo.getCurrentUser();
        if (currentUser!.role == "merchant") {
          _currentMerchant = await _merchantRepo.getCurrentMerchant();
        }
      }
      _isInitialized = true;
      notifyListeners();
      return true; // Tambahkan return value
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  Merchant? get currentMerchant => _currentMerchant;

  Future<bool> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepo.register(email, password, name, role);
      login(email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepo.login(email, password);
      // Simpan data user ke shared preferences
      _authRepo.saveUser(_currentUser!);
      _saveToken(_currentUser!.token!);

      if (currentUser!.role == "merchant") {
        _currentMerchant = await _merchantRepo.getMerchantById(
          currentUser!.id,
          _currentUser!.token!,
        );
        _merchantRepo.saveMerchant(_currentMerchant!);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepo.logout(_token!);
      _currentUser = null;
      _token = null;
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

  Future<bool> updateUser(String name, String email, File? image) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authRepo.updateUser(_currentUser!.id, name, _token!);
      _currentUser = user;
      if (image != null) {
        _currentUser!.photoUrl = await _authRepo.uploadImage(
          image,
          _currentUser!.id,
          _token!,
        );
      }
      _authRepo.saveUser(user);

      return true;
    } catch (e) {
      print("error update merchant $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMerchant(
    String description,
    String openHour,
    String closeHour,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final merchant = await _merchantRepo.updateMerchant(
        description,
        openHour,
        closeHour,
        _currentUser!.id,
        _token!,
      );
      _currentMerchant = merchant;
      _merchantRepo.saveMerchant(merchant);
      return true;
    } catch (e) {
      print("error update merchant $e");
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
