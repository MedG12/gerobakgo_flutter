import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/features/auth/widgets/login_page.dart';
import 'package:gerobakgo_with_api/features/auth/widgets/register_page.dart';
import 'package:gerobakgo_with_api/features/chats/screens/chat_page.dart';
import 'package:gerobakgo_with_api/features/maps/screens/map_page.dart';
import 'package:gerobakgo_with_api/features/user/detail/screen/detail_page.dart';
import 'package:gerobakgo_with_api/features/user/main/screen/main_shell.dart';
import 'package:gerobakgo_with_api/features/splash/screens/splash_screen.dart';
import 'package:gerobakgo_with_api/features/user/home/screen/home_page.dart';
import 'package:gerobakgo_with_api/features/user/profile/screen/profile_page.dart';
import 'package:go_router/go_router.dart';

final $appRoutes = [
  GoRoute(
    path: '/splash',
    pageBuilder:
        (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
  ),
  GoRoute(
    path: '/login',
    pageBuilder:
        (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
  ),
  GoRoute(
    path: '/register',
    pageBuilder:
        (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
  ),
  ShellRoute(
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: '/home',
        pageBuilder:
            (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomePage()),
      ),

      GoRoute(
        path: '/maps',
        pageBuilder:
            (context, state) =>
                NoTransitionPage(key: state.pageKey, child: MapPage()),
      ),
     
      GoRoute(
        path: '/chats',
        pageBuilder:
            (context, state) =>
                NoTransitionPage(key: state.pageKey, child: ChatPage()),
      ),

      GoRoute(
        path: '/profile',
        pageBuilder:
            (context, state) =>
                NoTransitionPage(key: state.pageKey, child: ProfilePage()),
      ),
    ],
  ),
  GoRoute(
    path: '/home/detail/:id',
    pageBuilder: (context, state) {
      final id = state.pathParameters['id'];
      return NoTransitionPage(
        key: state.pageKey,
        child: DetailScreen(merchantId: id!),
      );
    },
  ),
];
