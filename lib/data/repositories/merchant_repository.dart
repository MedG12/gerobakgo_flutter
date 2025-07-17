import 'dart:convert';
import 'dart:io';

import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:gerobakgo_with_api/data/models/menu_model.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/services/APIService.dart';
import 'package:gerobakgo_with_api/data/services/PusherService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantRepository {
  APIService _apiService = APIService();
  PusherService _pusherService = PusherService();

  MerchantRepository(this._apiService, this._pusherService);

  Stream<Location> getLocationStream() async* {
    await _pusherService.intializePusher();
    yield* _pusherService.stream;
  }

  Future<Merchant> getCurrentMerchant() async {
    final prefs = await SharedPreferences.getInstance();
    final merchantJson = prefs.getString('merchant');
    try {
      final merchantMap = jsonDecode(merchantJson!) as Map<String, dynamic>;
      return Merchant.fromJson(merchantMap);
    } catch (e) {
      print("error get merchant from cache : $e");
      throw Exception("error getting merchant data from cache :  $e");
    }
  }

  Future<Merchant> updateMerchant(
    String description,
    String openHour,
    String closeHour,
    int id,
    String token,
  ) async {
    return await _apiService.updateMerchant(
      description,
      openHour,
      closeHour,
      id,
      token,
    );
  }

  Future<void> saveMerchant(Merchant merchant) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('merchant')) await prefs.remove('merchant');
    await prefs.setString(
      'merchant',
      jsonEncode(merchant.toJson()),
    ); // Objek → JSON → String
  }

  Future<List<Merchant>> getMerchants(String token) async {
    return await _apiService.getMerchants(token);
  }

  Future<Merchant> getMerchantById(int id, String token) async {
    return await _apiService.getMerchantById(id, token);
  }

  Future<String> uploadMenuImage(File file, int? id, token) async {
    return await _apiService.uploadMenuImage(file, id, token);
  }

  Future<Menu> createMenu(Menu menu, int userId, String token) async {
    return await _apiService.addMenu(menu, userId, token);
  }

  Future<Menu> updateMenu(Menu menu, String token) async {
    return await _apiService.updateMenu(menu, token);
  }
}
