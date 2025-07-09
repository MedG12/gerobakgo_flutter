import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/services/APIService.dart';
import 'package:gerobakgo_with_api/data/services/PusherService.dart';

class MerchantRepository {
  APIService _apiService = APIService();
  PusherService _pusherService = PusherService();

  MerchantRepository(this._apiService, this._pusherService);

  Stream<Location> getLocationStream() async* {
    await _pusherService.intializePusher();
    yield* _pusherService.stream;
  }

  Future<List<Merchant>> getMerchants(String token) async {
    print('hit get merchants');
    return await _apiService.getMerchants(token);
  }

  Future<Merchant> getMerchantById(int id, String token) async {
    return await _apiService.getMerchantById(id, token);
  }
}
