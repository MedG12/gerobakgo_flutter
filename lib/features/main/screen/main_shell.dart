import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:gerobakgo_with_api/core/widgets/navItem.dart';
import 'package:gerobakgo_with_api/core/widgets/navItemProfile.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewmodel>();
    final isMerchant = authViewModel.currentUser?.role == "merchant";
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              if (isMerchant) {
                context.go('/dashboard');
              } else {
                context.go('/home');
              }
              break;

            case 1:
              context.go('/maps');
              break;

            case 2:
              context.go('/chats');
              break;

            case 3:
              if (isMerchant) {
                context.go('/profile-merchant');
              } else {
                context.go('/profile-user');
              }
              break;
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryDark,
        unselectedItemColor: AppTheme.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '', // Tambahkan label kosong
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: navItemProfile(context, _currentIndex == 3),
            label: '',
          ),
        ],
      ),
    );
  }
}
