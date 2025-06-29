// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gerobakgo_with_api/data/services/APIService.dart';
import 'package:gerobakgo_with_api/ui/core/app_wrappers/auth_wrapper.dart';
import 'package:gerobakgo_with_api/ui/auth/widgets/login_page.dart';
import 'package:gerobakgo_with_api/ui/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/ui/profile/widgets/profile_page.dart';
import 'package:gerobakgo_with_api/ui/auth/widgets/register_page.dart';
import 'package:provider/provider.dart';
import 'data/repositories/auth_repository.dart';
import 'ui/core/view_models/auth_viewmodel.dart';

void main() {
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
          // '/edit-profile': (context) => const EditProfilePage(),
        },
      ),
    ),
  );
}
