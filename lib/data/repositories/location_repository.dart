import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:gerobakgo_with_api/data/services/APIService.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationRepository {
  APIService _apiService;

  LocationRepository(this._apiService);

  Future<void> initialize() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika tidak aktif, minta pengguna mengaktifkannya
      serviceEnabled = await Geolocator.openLocationSettings();

      if (!serviceEnabled) {
        Future.error("Location Service disabled");
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permissions are denied.');
      }
    }
  }

  Future<LatLng> getCurrentPosition() async {
    final Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  Future<void> updateLocation(String token, Location location) async {
    await _apiService.updateLocation(token, location);
  }
}
