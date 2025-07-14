import 'package:flutter/foundation.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';

class DetailViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;
  int merchantId = 0;
  bool isInitialized = false;
  Merchant? merchant;

  DetailViewmodel(this._merchantRepository);

  Future<void> getMerchantById(id, String token) async {
    try {
      merchant = await _merchantRepository.getMerchantById(id, token);
      isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('err $e');
      throw Exception('error');
    }
  }

  void reset() {
    merchantId = 0;
    isInitialized = false;
    merchant = null;
    notifyListeners();
  }
}
