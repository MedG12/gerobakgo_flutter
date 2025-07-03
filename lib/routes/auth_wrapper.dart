import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<void> _initialize(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.init();
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialize(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final authViewModel = context.read<AuthViewModel>();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authViewModel.token != null) {
              Navigator.pushReplacementNamed(context, '/user/home');
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Lottie.asset(
                'assets/animations/splash_animation.json',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Lottie.asset(
                'assets/animations/splash_animation.json',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          );
        }
      },
    );
  }
}
