// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gerobakgo_with_api/data/repositories/merchant_repository.dart';
import 'package:gerobakgo_with_api/data/services/APIService.dart';
import 'package:gerobakgo_with_api/ui/core/app_wrappers/auth_wrapper.dart';
import 'package:gerobakgo_with_api/ui/auth/widgets/login_page.dart';
import 'package:gerobakgo_with_api/ui/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/ui/user/home/ui/home.dart';
import 'package:gerobakgo_with_api/ui/user/home/view_model/home_viewmodel.dart';
import 'package:gerobakgo_with_api/ui/user/profile/widgets/profile_page.dart';
import 'package:gerobakgo_with_api/ui/auth/widgets/register_page.dart';
import 'package:provider/provider.dart';
import 'data/repositories/auth_repository.dart';
import 'ui/core/view_models/auth_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  try {
    await dotenv.load(fileName: ".env"); // Load environment variables
  } catch (e) {
    throw Exception('Error loading .env file: $e'); // Print error if any
  }
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => APIService()),
        ChangeNotifierProvider(
          create:
              (context) => AuthViewModel(
                AuthRepository(
                  context.read<APIService>(),
                  const FlutterSecureStorage(),
                ),
              ),
        ),

        // Provider<MerchantRepository>(
        //   create: (context) => MerchantRepository(context.read<APIService>()),
        // ),
        ChangeNotifierProvider(
          create:
              (context) => HomeViewmodel(
                MerchantRepository(context.read<APIService>()),
                context.read<AuthViewModel>(),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/profile': (context) => ProfilePage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/user/home': (context) => HomePage(),
          // '/edit-profile': (context) => const EditProfilePage(),
        },
      ),
    ),
  );
}
