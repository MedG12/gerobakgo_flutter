import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    // Pastikan ini dijalankan setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isInitialized) {
        final HomeViewmodel homeViewmodel = Provider.of<HomeViewmodel>(
          context,
          listen: false,
        );
        final AuthViewmodel authViewmodel = Provider.of<AuthViewmodel>(
          context,
          listen: false,
        );
        homeViewmodel.token = authViewmodel.token!;
        homeViewmodel.fetchLocation();
        await homeViewmodel.fetchMerchants();

        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final HomeViewmodel homeViewmodel = Provider.of<HomeViewmodel>(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 250,
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
                      child:
                          homeViewmodel.city != null
                              ? Column(
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
                                          homeViewmodel.city ?? '',
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
                              )
                              : Text(""),
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
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            Consumer<HomeViewmodel>(
              builder: (context, homeViewmodel, child) {
                if (homeViewmodel.merchants.isEmpty && _isInitialized) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada merchant yang cocok.'),
                    ),
                  );
                }

                if (homeViewmodel.merchants.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final merchant = homeViewmodel.merchants[index];
                    return merchantCard(context, merchant, true);
                  }, childCount: homeViewmodel.merchants.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
