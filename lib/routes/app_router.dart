import 'package:gerobakgo_with_api/routes/routes.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/splash',
      routes: $appRoutes,
      redirect: (BuildContext context, GoRouterState state) async {
        final authViewModel = context.read<AuthViewmodel>();
        if (!authViewModel.isInitialized) {
          await authViewModel.init();
        }

        final isMerchant = authViewModel.currentUser?.role == "merchant";
        final isLoggedIn = authViewModel.token != null;
        final isSplash = state.matchedLocation == '/splash';
        final isAuthRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!isLoggedIn && !isAuthRoute && !isSplash) {
          return '/login';
        }

        if (isLoggedIn && isAuthRoute && !isSplash) {
          if (isMerchant) {
            return '/dashboard';
          } else {
            return '/home';
          }
        }

        return null;
      },
      errorBuilder:
          (context, state) => Scaffold(
            body: Center(
              child: Text('Route not found: ${state.matchedLocation}'),
            ),
          ),
    );
  }
}
