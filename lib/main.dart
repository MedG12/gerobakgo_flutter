// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gerobakgo_with_api/services/APIService.dart';
import 'package:gerobakgo_with_api/views/profile_page.dart';
import 'package:provider/provider.dart';
import 'repositories/auth_repository.dart';
import 'view_models/auth_viewmodel.dart';
import 'views/login_page.dart';

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
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/profile': (context) => ProfilePage(),
          // '/edit-profile': (context) => const EditProfilePage(),
        },
        // home: LoginPage(),
      ),
    ),
  );
}
