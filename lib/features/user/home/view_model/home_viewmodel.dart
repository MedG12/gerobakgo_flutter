import 'package:flutter/foundation.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/location_repository.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';

class HomeViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;
  final LocationRepository _locationRepository;
  List<Merchant> merchants = [];
  String? _token;
  bool _isLoading = false;
  String? _city;

  get city => _city;

  HomeViewmodel(this._merchantRepository, this._locationRepository) {
    _locationRepository.initialize();
  }

  bool get isLoading => _isLoading;

  set token(String token) {
    _token = token;
    if (mounted) {
      notifyListeners();
    }
  }

  Future<void> fetchLocation() async {
    try {
      final location = await _locationRepository.getCurrentPosition();
      final cityName = await _locationRepository.getCityNameFromOSM(
        location.latitude,
        location.longitude,
      );
      _city = cityName;
      notifyListeners();
    } catch (e) {
      debugPrint("error $e");
    }
  }

  Future<List<Merchant>> fetchMerchants() async {
    if (_isLoading) return merchants; // Prevent multiple calls

    _isLoading = true;
    notifyListeners();

    try {
      if (_token != null) {
        merchants = await _merchantRepository.getMerchants(_token!);
        return merchants;
      } else {
        throw Exception('Token is not available');
      }
    } catch (e) {
      debugPrint("Error fetching merchants in home view $e");
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get mounted => hasListeners;
}
