import 'package:flutter/foundation.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';

class HomeViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;
  final AuthViewmodel _authViewModel;
  List<Merchant> merchants = [];

  HomeViewmodel(this._merchantRepository, this._authViewModel) {
    fetchMerchants();
    // _merchantRepository.getLocationStream().listen((location) {
    //   merchants.forEach((merchant) {
    //     if (location.id == merchant.id) {
    //       merchant.location = location;
    //     }
    //   });
    // });
  }
  // Example method to fetch merchants
  Future<List<Merchant>> fetchMerchants() async {
    try {
      final token = _authViewModel.token;
      if (token != null) {
        merchants = await _merchantRepository.getMerchants(token);
        return merchants;
      } else {
        throw Exception('Token is not available');
      }
    } catch (e) {
      print("Error fetching merchants in home view $e");
      // Handle error
      return [];
    } finally {
      notifyListeners(); // Notify listeners after fetching merchants
    }
  }

  String currentCity = 'Depok';

  // Example method to update the current city
  void updateCity(String newCity) {
    currentCity = newCity;
    notifyListeners();
  }
}
