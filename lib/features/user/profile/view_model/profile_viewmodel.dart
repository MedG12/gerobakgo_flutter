import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileViewmodel with ChangeNotifier {
  String _originalName = '';
  String _currentName = '';
  File? _selectedImage;
  bool _isUploading = false;

  String get currentName => _currentName;
  String get originalName => _originalName;

  void reset() {
    _currentName =  _originalName;
    _selectedImage = null;
    _isUploading = false;
    notifyListeners();
  }

  set currentName(String name) {
    _currentName = name;
    notifyListeners();
  }

  // Set nilai awal saat pertama kali masuk halaman
  void setOriginalName(String name) {
    _originalName = name;
    _currentName = name;
    notifyListeners();
  }

  bool get isNameChanged => _originalName != _currentName;
  File? get selectedImage => _selectedImage;

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
      debugPrint('Image picker error: $e');
      rethrow;
    }
  }

  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }
}
