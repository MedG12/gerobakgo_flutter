import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:gerobakgo_with_api/core/widgets/merchantCard.dart';
import 'package:gerobakgo_with_api/features/merchant/dashboard/screen/add_edit_form.dart';
import 'package:gerobakgo_with_api/features/merchant/dashboard/screen/menuCard.dart';
import 'package:gerobakgo_with_api/features/merchant/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const DashboardPage({super.key, this.onNavigateToProfile});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authViewmodel = context.read<AuthViewmodel>();
      final dashboardViewmodel = context.read<DashboardViewmodel>();
      dashboardViewmodel.userId = authViewmodel.currentUser!.id;
      dashboardViewmodel.token = authViewmodel.token!;

      await dashboardViewmodel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardViewmodel = context.watch<DashboardViewmodel>();
    if (dashboardViewmodel.isInitialized) print(dashboardViewmodel.id);
    return SafeArea(
      child: Scaffold(
        body:
            dashboardViewmodel.isInitialized
                ? CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 16.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          'Dashboard',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: merchantCard(
                        context,
                        dashboardViewmodel.merchant!,
                        false,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'Menu Saya',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Menucard(menu: dashboardViewmodel.menus[index]);
                      }, childCount: dashboardViewmodel.menus.length),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                )
                : Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => AddEditMenuForm(),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          tooltip: 'Tambah Menu',
        ),
      ),
    );
  }
}
