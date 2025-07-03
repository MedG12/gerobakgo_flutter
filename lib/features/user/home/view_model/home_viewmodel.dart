import 'package:flutter/foundation.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';

class HomeViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;
  final AuthViewModel _authViewModel;
  List<Merchant> merchants = [];

  HomeViewmodel(this._merchantRepository, this._authViewModel) {
    // Initialize or fetch data here if needed
    fetchMerchants();
  }
  // Example method to fetch merchants
  Future<List<Merchant>> fetchMerchants() async {
    try {
      final token = _authViewModel.token;
      if (token != null) {
        merchants = await _merchantRepository.getMerchants(token);
        return merchants;
      } else {
        // Handle case where token is not available
        print('Token is not available');
        return [];
      }
    } catch (e) {
      // Handle error
      print('Error fetching merchants: $e');
      return [];
    } finally {
      notifyListeners(); // Notify listeners after fetching merchants
    }
  }

  // Example property
  String currentCity = 'Depok';

  // Example method to update the current city
  void updateCity(String newCity) {
    currentCity = newCity;
    notifyListeners();
  }
}
