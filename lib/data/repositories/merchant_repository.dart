import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/services/APIService.dart';

class MerchantRepository {
  APIService _apiService = APIService();

  MerchantRepository(this._apiService);

  Future<List<Merchant>> getMerchants(String token) async {
    return await _apiService.getMerchants(token);
  }

  Future<Merchant> getMerchantById(String id, String token) async {
    return await _apiService.getMerchantById(id, token);
  }
}
