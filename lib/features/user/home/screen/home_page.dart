import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/widgets/merchantCard.dart';
import 'package:gerobakgo_with_api/features/user/home/view_model/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    final HomeViewmodel _homeViewModel = Provider.of<HomeViewmodel>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeViewModel.fetchMerchants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final HomeViewmodel _homeViewModel = Provider.of<HomeViewmodel>(
      context,
      listen: false,
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 250, // Tinggi gambar
              backgroundColor: Colors.transparent,
              floating: false,
              pinned: true,
              toolbarHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20.0),
                background: Stack(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/img_city.png',
                      alignment: Alignment.topCenter,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's on",
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_sharp,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              Flexible(
                                child: Text(
                                  'Depok',
                                  style: TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              title: SizedBox(
                height: 45,
                child: SearchBar(
                  controller: _searchController,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  hintText: 'Cari disini...',
                  trailing: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        // Optional jika ingin trigger search manual
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder(
              future:
                  _homeViewModel.merchants.isNotEmpty
                      ? Future.value(_homeViewModel.merchants)
                      : _homeViewModel.fetchMerchants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }

                final merchants = _homeViewModel.merchants;
                if (merchants.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada merchant yang cocok.'),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final merchant = merchants[index];
                    return merchantCard(context, merchant);
                  }, childCount: merchants.length),
                );
              },
            ),

            // StreamBuilder<List<MerchantModel>>(
            //   stream: _merchantService.getMerchants(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const SliverFillRemaining(
            //         child: Center(child: CircularProgressIndicator()),
            //       );
            //     }

            //     if (snapshot.hasError) {
            //       return SliverFillRemaining(
            //         child: Center(child: Text('Error: ${snapshot.error}')),
            //       );
            //     }

            //     final merchants = snapshot.data ?? [];
            //     final filteredMerchants = _filterMerchants(merchants);

            //     if (filteredMerchants.isEmpty) {
            //       return const SliverFillRemaining(
            //         child: Center(
            //           child: Text('Tidak ada merchant yang cocok.'),
            //         ),
            //       );
            //     }

            //     return StreamBuilder<Map<String, LatLng>>(
            //       stream: locationService.getActiveLocations(),
            //       builder: (context, snapshot) {
            //         final activeMerchants = snapshot.data ?? {};
            //         return FutureBuilder<Position>(
            //           future: userLocation,
            //           builder: (context, userLocationSnapshot) {
            //             if (userLocationSnapshot.connectionState !=
            //                 ConnectionState.done) {
            //               return const SliverFillRemaining(
            //                 child: Center(child: CircularProgressIndicator()),
            //               );
            //             }

            //             final userPos = userLocationSnapshot.data;

            //             return SliverFillRemaining(
            //               child: ClipRRect(
            //                 borderRadius: const BorderRadius.vertical(
            //                   top: Radius.circular(20),
            //                 ),
            //                 child: Container(
            //                   color: Colors.white,
            //                   child: ListView.builder(
            //                     physics: const NeverScrollableScrollPhysics(),
            //                     padding: const EdgeInsets.symmetric(
            //                       vertical: 16,
            //                     ),
            //                     itemCount: filteredMerchants.length,
            //                     itemBuilder: (context, index) {
            //                       final merchant = filteredMerchants[index];
            //                       String distanceText = 'N/A';

            //                       if (activeMerchants.containsKey(
            //                             merchant.uid,
            //                           ) &&
            //                           userPos != null) {
            //                         final location =
            //                             activeMerchants[merchant.uid];
            //                         if (location != null) {
            //                           final distance =
            //                               Geolocator.distanceBetween(
            //                                 userPos.latitude,
            //                                 userPos.longitude,
            //                                 location.latitude,
            //                                 location.longitude,
            //                               ) /
            //                               1000;
            //                           distanceText =
            //                               '${distance.toStringAsFixed(1)} km';
            //                         }
            //                       }
            //                       return sellerCard(
            //                         context,
            //                         Merchant(
            //                           id: merchant.uid,
            //                           name: merchant.name,
            //                           description: merchant.description,
            //                           imagePath: merchant.photoUrl,
            //                           distance: distanceText,
            //                           openHours: merchant.openHours,
            //                           location: activeMerchants[merchant.uid],
            //                         ),
            //                       );
            //                     },
            //                   ),
            //                 ),
            //               ),
            //             );
            //           },
            //         );
            //       },
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
