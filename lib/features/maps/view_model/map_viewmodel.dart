import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:latlong2/latlong.dart';

class MapViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;

  int? _userId;
  Timer? _expiryTimer;
  StreamSubscription? _locationStreamSubscription;
  List<Merchant>? merchants;
  bool _isLoading = false;
  bool _isInitialized = false;

  final ValueNotifier<List<Merchant>> markersNotifier = ValueNotifier([]);
  Map<int, Merchant> activeMerchants = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasActiveMerchants => activeMerchants.isNotEmpty;

  set userId(int id) {
    _userId = id;
    notifyListeners();
  }

  MapViewmodel(this._merchantRepository) {
    _setupExpiryTimer();
    _setupLocationStream();
  }

  void _setupExpiryTimer() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _removeExpiredMerchants();
    });
  }

  void _setupLocationStream() {
    _locationStreamSubscription = _merchantRepository
        .getLocationStream()
        .listen(
          (location) {
            _handleLocationUpdate(location);
          },
          onError: (error) {
            print('Location stream error: $error');
          },
        );
  }

  void _handleLocationUpdate(Location location) {
    // Jika merchant belum ada di activeMerchants, tambahkan
    if (activeMerchants[location.id] == null && merchants != null) {
      try {
        final merchant = merchants!.firstWhere(
          (merchant) => merchant.id == location.id,
        );
        activeMerchants[merchant.id] = merchant;
        print('New merchant added: ${merchant.id}');
      } catch (e) {
        print('Merchant with id ${location.id} not found in merchants list');
        return;
      }
    }

    // Update location
    if (activeMerchants[location.id] != null) {
      activeMerchants[location.id]!.location = location;
      _updateMarkers();
    }
  }

  Future<void> initializeActiveMerchants(String token) async {
    if (_isInitialized) return;

    _setLoading(true);

    try {
      merchants = await _merchantRepository.getMerchants(token);
      print('initialized with ${merchants?.length} inactive');
      activeMerchants.clear();

      // Tambahkan merchant yang memiliki location
      for (var merchant in merchants!) {
        if (merchant.location != null) {
          activeMerchants[merchant.id] = merchant;
        }
      }

      _updateMarkers();
      _isInitialized = true;
      print('Initialized with ${activeMerchants.length} active merchants');
    } catch (e) {
      print('Error getting merchants: $e');
      // Tidak throw error, biarkan map tetap berjalan
      // User akan melihat map kosong tapi masih bisa menerima update real-time
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshMerchants(String token) async {
    _setLoading(true);

    try {
      merchants = await _merchantRepository.getMerchants(token);
      for (var merchant in merchants!) {
        if (activeMerchants.containsKey(merchant.id)) {
          activeMerchants[merchant.id] = merchant;
        }
      }
      _updateMarkers();
    } catch (e) {
      print('Error refreshing merchants: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _updateMarkers() {
    final updatedMarkers =
        activeMerchants.values
            .where(
              (merchant) => merchant.id != _userId && merchant.location != null,
            )
            .toList();

    markersNotifier.value = updatedMarkers;
  }

  void _removeExpiredMerchants() {
    if (activeMerchants.isEmpty) return;

    final now = DateTime.now();
    final expiredIds = <int>[];

    for (var merchant in activeMerchants.values) {
      final lastUpdated = merchant.location?.lastUpdated;
      if (lastUpdated == null) continue;

      if (now.difference(lastUpdated).inMinutes >= 10) {
        expiredIds.add(merchant.id);
      }
    }

    for (var id in expiredIds) {
      activeMerchants.remove(id);
    }

    if (expiredIds.isNotEmpty) {
      print('Removed ${expiredIds.length} expired merchants');
      _updateMarkers();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _locationStreamSubscription?.cancel();
    markersNotifier.dispose();
    super.dispose();
  }

  // Method untuk debugging
  void printActiveMerchants() {
    print('Active merchants count: ${activeMerchants.length}');
    for (var merchant in activeMerchants.values) {
      print(
        'Merchant ${merchant.id}: ${merchant.location?.latitude}, ${merchant.location?.longitude}',
      );
    }
  }
}
