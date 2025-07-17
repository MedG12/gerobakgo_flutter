import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:image_picker/image_picker.dart';

class ProfileMerchViewmodel extends ChangeNotifier {
  final MerchantRepository _merchantRepository;

  // Original values for comparison
  String _originalName = '';
  String? _originalDescription;
  TimeOfDay? _originalOpenHour;
  TimeOfDay? _originalCloseHour;

  // Current values
  String _currentName = '';
  String? _currentDescription;
  TimeOfDay? _currentOpenHour;
  TimeOfDay? _currentCloseHour;

  // State management
  Merchant? _merchant;
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileMerchViewmodel(this._merchantRepository);

  // Getters
  String get originalName => _originalName;
  String? get originalDescription => _originalDescription;
  TimeOfDay? get originalOpenHour => _originalOpenHour;
  TimeOfDay? get originalCloseHour => _originalCloseHour;

  String get currentName => _currentName;
  String? get currentDescription => _currentDescription;
  TimeOfDay? get currentOpenHour => _currentOpenHour;
  TimeOfDay? get currentCloseHour => _currentCloseHour;

  Merchant? get merchant => _merchant;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  set currentName(String value) {
    _currentName = value;
    notifyListeners();
  }

  set currentDescription(String? value) {
    _currentDescription = value;
    notifyListeners();
  }

  set currentOpenHour(TimeOfDay? value) {
    _currentOpenHour = value;
    notifyListeners();
  }

  set currentCloseHour(TimeOfDay? value) {
    _currentCloseHour = value;
    notifyListeners();
  }

  // Check if any value has changed
  bool get userHasChanges =>
      _originalName != _currentName || _selectedImage != null;

  bool get merchHasChanges =>
      _originalDescription != _currentDescription ||
      _originalOpenHour != _currentOpenHour ||
      _originalCloseHour != _currentCloseHour;

  // Initialize with original values
  void setOriginalValues({
    required String name,
    String? description,
    TimeOfDay? openHour,
    TimeOfDay? closeHour,
  }) {
    _originalName = name;
    _originalDescription = description;
    _originalOpenHour = openHour;
    _originalCloseHour = closeHour;

    // Set current values to original values
    _currentName = name;
    _currentDescription = description;
    _currentOpenHour = openHour;
    _currentCloseHour = closeHour;

    notifyListeners();
  }

  // Reset to original values
  void resetToOriginal() {
    _currentName = _originalName;
    _currentDescription = _originalDescription;
    _currentOpenHour = _originalOpenHour;
    _currentCloseHour = _originalCloseHour;
    _selectedImage = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch merchant data
  Future<void> fetchMerchant(int id, String token) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _merchant = await _merchantRepository.getMerchantById(id, token);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch merchant data: $e';
      debugPrint('Error fetching merchant: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      debugPrint('Image picker error: $e');
    }
  }

  // Remove selected image
  void removeSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
