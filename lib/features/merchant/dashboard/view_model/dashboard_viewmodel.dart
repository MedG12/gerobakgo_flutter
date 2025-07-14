import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:gerobakgo_with_api/core/exceptions/app_exceptions.dart';
import 'package:gerobakgo_with_api/data/repositories/location_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gerobakgo_with_api/data/models/menu_model.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';

class DashboardViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;
  final LocationRepository _locationRepository;
  Merchant? _merchant;
  String? _token;
  final List<Menu> menus = [];
  bool _isLoading = false;
  File? _selectedImage;
  int? userId;
  bool _isInitialized = false;
  Map<String, dynamic> errorMessage = {};
  String? existingImageUrl;

  // Getters
  Merchant? get merchant => _merchant;
  bool get isLoading => _isLoading;
  File? get selectedImage => _selectedImage;
  bool get isInitialized => _isInitialized;

  DashboardViewmodel(this._merchantRepository, this._locationRepository);

  get id => userId;
  // get token => _token;

  // Set authentication token
  set token(String token) {
    _token = token;
  }

  Future<void> init() async {
    await getMerchant(userId!, _token!);
    await _locationRepository.initialize();
    _isInitialized = true;
    notifyListeners();
  }

  // Get merchant data
  Future<void> getMerchant(int id, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _merchant = await _merchantRepository.getMerchantById(id, token);
      if (_merchant != null) {
        menus.clear();
        menus.addAll(_merchant!.menus ?? []);
      }
    } catch (e) {
      debugPrint('Error getting merchant: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      rethrow;
    }
  }

  // Add new menu
  Future<bool> addMenu(String name, String description, String price) async {
    try {
      // First upload image if exists
      if (_token == null) throw TokenException();
      if (_merchant == null) throw MerchantException();
      if (_selectedImage == null) throw FieldException(field: "Gambar");
      _isLoading = true;
      notifyListeners();

      String photoUrl = await _merchantRepository.uploadMenuImage(
        _selectedImage!,
        null,
        _token,
      );

      final menu = Menu(
        name: name,
        description: description,
        price: price,
        photoUrl: photoUrl,
      );
      final createdMenu = await _merchantRepository.createMenu(
        menu,
        userId!,
        _token!,
      );

      menus.add(createdMenu);
      notifyListeners();
      return true;
    } on TokenException catch (e) {
      errorMessage["token"] = e.message;
      return false;
    } on FieldException catch (e) {
      errorMessage["image"] = e.message;
      return false;
    } catch (e) {
      debugPrint('Error adding menu: $e');
      return false;
    } finally {
      _isLoading = false;
      _selectedImage = null;
      notifyListeners();
    }
  }

  // Update existing menu
  Future<bool> updateMenu(Menu menu) async {
    if (_token == null) throw TokenException('Token not available');

    _isLoading = true;
    notifyListeners();

    try {
      // Upload new image if selected
      String? imageUrl = menu.photoUrl;
      if (_selectedImage != null) {
        imageUrl = await _merchantRepository.uploadMenuImage(
          _selectedImage!,
          menu.id,
          _token!,
        );
      }

      // Update menu with new data
      final updatedMenu = menu.copyWith(photoUrl: imageUrl);

      final result = await _merchantRepository.updateMenu(updatedMenu, _token!);

      // Update local list
      final index = menus.indexWhere((m) => m.id == menu.id);
      if (index != -1) {
        menus[index] = result;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating menu: $e');
      return false;
    } finally {
      _isLoading = false;
      _selectedImage = null;
      notifyListeners();
    }
  }

  // Clear selected image
  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }
}
