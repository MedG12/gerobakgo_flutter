import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/features/maps/screens/marker.dart';
import 'package:gerobakgo_with_api/features/maps/view_model/map_viewmodel.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapController = MapController();
  final userLatLng = LatLng(36.0, 44.0);
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    if (_isInitialized) return;

    final authViewModel = Provider.of<AuthViewmodel>(context, listen: false);
    final mapViewModel = Provider.of<MapViewmodel>(context, listen: false);

    try {
      await mapViewModel.initializeActiveMerchants(authViewModel.token!);
    } catch (e) {
      // Error sudah di-handle di viewmodel
      print('Error initializing merchants: $e');
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapViewModel = Provider.of<MapViewmodel>(context);

    return Scaffold(
      body:
          _isInitialized
              ? _buildMap(mapViewModel)
              : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMap(MapViewmodel mapViewModel) {
    void showMerchantModal(BuildContext context, Merchant merchant) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                merchantMarker(merchant),
                const SizedBox(height: 16),

                // Name
                Text(
                  merchant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  merchant.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Button: Ingatkan Saya
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Ingatkan Saya'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // proximityService.addTaggedMerchant(merchant.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Button: Kirim Pesan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Pesan'),
                    iconAlignment: IconAlignment.end,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: userLatLng, initialZoom: 18),
      children: [
        // Tile layer
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        // User marker
        MarkerLayer(
          markers: [
            Marker(
              rotate: true,
              width: 80,
              height: 80,
              point: userLatLng,
              child: const Icon(Icons.circle, color: Colors.blue, size: 20),
            ),
          ],
        ),
        // Merchant markers dengan ValueListenableBuilder
        ValueListenableBuilder<List<Merchant>>(
          valueListenable: mapViewModel.markersNotifier,
          builder: (context, merchants, _) {
            final markers =
                merchants
                    .map(
                      (merchant) => Marker(
                        rotate: true,
                        point: LatLng(
                          merchant.location!.latitude,
                          merchant.location!.longitude,
                        ),
                        child: GestureDetector(
                          onTap: () => {showMerchantModal(context, merchant)},
                          child: merchantMarker(merchant),
                        ),
                      ),
                    )
                    .toList();
            return MarkerLayer(markers: markers);
          },
        ),
        // Loading indicator overlay
        if (mapViewModel.isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
