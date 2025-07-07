import 'package:flutter/foundation.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';

class DetailViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;
  int _merchantId = 0;

  DetailViewmodel(this._merchantRepository);
  set setMerchantId(int id) {
    _merchantId = id;
    notifyListeners();
  }

  Future<Merchant> getMerchantById(int id, String token) async {
    return await _merchantRepository.getMerchantById(id, token);
  }
}
