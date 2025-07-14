import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:gerobakgo_with_api/features/user/detail/view_model/detail_viewmodel.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final String merchantId;

  const DetailScreen({Key? key, required this.merchantId}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final detailViewModel = Provider.of<DetailViewmodel>(
        context,
        listen: false,
      );

      detailViewModel.reset();
      final authViewmodel = Provider.of<AuthViewmodel>(context, listen: false);
      await detailViewModel.getMerchantById(
        int.parse(widget.merchantId),
        authViewmodel.token!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailViewModel = Provider.of<DetailViewmodel>(context, listen: true);
    final merchant = detailViewModel.merchant;
    if (!detailViewModel.isInitialized) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Detail',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Merchant info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image:
                            merchant?.photoUrl != null
                                ? NetworkImage(
                                      dotenv.env['STORAGE_URL']! +
                                          merchant!.photoUrl!,
                                    )
                                    as ImageProvider
                                : const AssetImage(
                                  'assets/images/placeholder.png',
                                ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nama + deskripsi + tombol
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          merchant.description ?? "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      merchant.location == null
                                          ? Colors.grey
                                          : AppTheme.primaryDark,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'GO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Chat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child:
                        merchant.menus!.length > 0
                            ? ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: merchant.menus!.length,
                              itemBuilder: (context, index) {
                                final menuItem = merchant.menus![index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    children: [
                                      // Gambar menu
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(
                                                      dotenv.env["STORAGE_URL"]! +
                                                          menuItem.photoUrl!,
                                                    )
                                                    as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Info menu
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menuItem.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              menuItem.description,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              menuItem.price,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: Text(
                                'No menu available',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: AppTheme.grey),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
