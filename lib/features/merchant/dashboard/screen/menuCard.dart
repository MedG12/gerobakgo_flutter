import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/data/models/menu_model.dart';
import 'package:gerobakgo_with_api/features/merchant/dashboard/screen/add_edit_form.dart';

class Menucard extends StatelessWidget {
  Menu menu;
  Menucard({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                "${dotenv.env['STORAGE_URL']}${menu.photoUrl}",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.fastfood, color: Colors.grey[400]),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menu.price,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menu.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed:
                      () => showModalBottomSheet(
                        context: context,
                        builder: (_) => AddEditMenuForm(menu: menu),
                      ),
                  tooltip: 'Edit Menu',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => () {},
                  tooltip: 'Hapus Menu',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
