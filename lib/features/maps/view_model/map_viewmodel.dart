import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/data/models/user_model.dart';
import 'package:gerobakgo_with_api/data/repositories/location_repository.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:latlong2/latlong.dart';

class MapViewmodel with ChangeNotifier {
  final MerchantRepository _merchantRepository;
  final LocationRepository _locationRepository;

  User? _user;
  Timer? _expiryTimer;
  StreamSubscription? _locationStreamSubscription;
  StreamSubscription? _userLocationStreamSubscription;
  List<Merchant>? merchants;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _token;
  // Stream<LatLng> location;

  final ValueNotifier<List<Merchant>> markersNotifier = ValueNotifier([]);
  final ValueNotifier<LatLng?> userLocationNotifier = ValueNotifier(null);
  Map<int, Merchant> activeMerchants = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasActiveMerchants => activeMerchants.isNotEmpty;
  Stream<LatLng> get locationStream => _locationRepository.getLocationStream();
  User? get user => _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  set token(String token) {
    _token = token;
    notifyListeners();
  }

  MapViewmodel(this._merchantRepository, this._locationRepository) {
    // _locationRepository.initialize();
    _setupExpiryTimer();
    _setupMercStream();
    _setupUserStream();
  }

  void _setupExpiryTimer() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _removeExpiredMerchants();
    });
  }

  void _setupMercStream() {
    _locationStreamSubscription = _merchantRepository
        .getLocationStream()
        .listen(
          (location) {
            // Jika merchant belum ada di activeMerchants, tambahkan
            if (activeMerchants[location.id] == null && merchants != null) {
              try {
                final merchant = merchants!.firstWhere(
                  (merchant) => merchant.id == location.id,
                );
                activeMerchants[merchant.id] = merchant;
              } catch (e) {
                print(
                  'Merchant with id ${location.id} not found in merchants list',
                );
                return;
              }
            }

            // Update location
            if (activeMerchants[location.id] != null) {
              activeMerchants[location.id]!.location = location;
              _updateMarkers();
            }
          },
          onError: (error) {
            print('Location stream error: $error');
          },
        );
  }

  void _setupUserStream() {
    _userLocationStreamSubscription = _locationRepository
        .getLocationStream()
        .listen(
          (location) {
            userLocationNotifier.value = location;
            if (_user!.role == "merchant") {
              Location userLoc = Location(
                id: _user!.id,
                latitude: location.latitude,
                longitude: location.longitude,
                lastUpdated: DateTime.now(),
              );
              _locationRepository.updateLocation(_token!, userLoc);
            }
          },
          onError: (error) {
            print('User location stream error: $error');
          },
        );
  }

  Future<void> initializeActiveMerchants(String token) async {
    _setLoading(true);

    try {
      await _locationRepository.initialize();
      merchants = await _merchantRepository.getMerchants(token);
      activeMerchants.clear();

      // Tambahkan merchant yang memiliki location
      for (var merchant in merchants!) {
        if (merchant.location != null) {
          print("merchantnyaa : ${merchant.name}");
          activeMerchants[merchant.id] = merchant;
        }
      }

      _updateMarkers();
      _isInitialized = true;
    } catch (e) {
      print('Error getting merchants: $e');
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
              (merchant) =>
                  merchant.id != _user!.id && merchant.location != null,
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
    _userLocationStreamSubscription?.cancel();
    markersNotifier.dispose();
    super.dispose();
  }
}
