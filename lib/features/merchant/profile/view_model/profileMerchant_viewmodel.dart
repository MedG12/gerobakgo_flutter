import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:image_picker/image_picker.dart';

class ProfileMerchViewmodel extends ChangeNotifier {
  final MerchantRepository _merchantRepository;
  String _originalName = '';
  String _currentName = '';
  String? description;
  Merchant? merchant;
  File? selectedImage;
  bool _isUploading = false;

  String get currentName => _currentName;
  String get originalName => _originalName;

  ProfileMerchViewmodel(this._merchantRepository);
  void reset() {
    _currentName = _originalName;
    selectedImage = null;
    _isUploading = false;
    notifyListeners();
  }

  set currentName(String name) {
    _currentName = name;
    notifyListeners();
  }

  void setOriginalName(String name) {
    _originalName = name;
    _currentName = name;
    notifyListeners();
  }

  bool get isNameChanged => _originalName != _currentName;

  Future<void> getMerchantProfile(int id, String token) async {
    merchant = await _merchantRepository.getMerchantById(id, token);
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
      rethrow;
    }
  }

  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }
}
