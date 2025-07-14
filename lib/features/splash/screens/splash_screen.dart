import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Future.delayed(Duration(seconds: 2), () async {
      final authViewModel = context.read<AuthViewmodel>();
      await authViewModel.init();
      final isLoggedIn = authViewModel.token != null;
      final isMerchant = authViewModel.currentUser?.role == "merchant";
      if (!mounted) return;
      if (isLoggedIn) {
        if (isMerchant) {
          context.go('/dashboard');
        } else {
          context.go('/home');
        }
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash_animation.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
