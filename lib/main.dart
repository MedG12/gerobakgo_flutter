// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gerobakgo_with_api/data/repositories/location_repository.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:gerobakgo_with_api/data/services/APIService.dart';
import 'package:gerobakgo_with_api/features/maps/view_model/map_viewmodel.dart';
import 'package:gerobakgo_with_api/features/user/detail/view_model/detail_viewmodel.dart';
import 'package:gerobakgo_with_api/features/user/profile/view_model/profile_viewmodel.dart';
import 'package:gerobakgo_with_api/routes/app_router.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/features/user/home/view_model/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'data/repositories/auth_repository.dart';
import 'core/view_models/auth_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/data/services/PusherService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  try {
    await dotenv.load(fileName: ".env"); // Load environment variables
  } catch (e) {
    throw Exception('Error loading .env file: $e'); // Print error if any
  }
  final _appRouter = AppRouter();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => APIService()),
        Provider(create: (_) => PusherService()),
        ChangeNotifierProvider(
          create:
              (context) => AuthViewmodel(
                AuthRepository(
                  context.read<APIService>(),
                  const FlutterSecureStorage(),
                ),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => HomeViewmodel(
                MerchantRepository(
                  context.read<APIService>(),
                  context.read<PusherService>(),
                ),
                context.read<AuthViewmodel>(),
              ),
        ),
        ChangeNotifierProvider(create: (context) => ProfileViewmodel()),
        ChangeNotifierProvider(
          create:
              (context) => DetailViewmodel(
                MerchantRepository(
                  context.read<APIService>(),
                  context.read<PusherService>(),
                ),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => MapViewmodel(
                MerchantRepository(
                  context.read<APIService>(),
                  context.read<PusherService>(),
                ),
                LocationRepository(context.read<APIService>()),
              ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _appRouter.router,
      ),
    ),
  );
}
