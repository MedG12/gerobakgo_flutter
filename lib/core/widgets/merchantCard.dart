import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

Widget merchantCard(BuildContext context, Merchant merchant, bool isHomePage) {
  return GestureDetector(
    onTap: () async {
      if (isHomePage) context.push('/home/detail/${merchant.userId}');
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Merchant image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image:
                    merchant.photoUrl != null
                        ? NetworkImage(
                          "${dotenv.env['STORAGE_URL']}${merchant.photoUrl!}",
                        )
                        : const AssetImage('assets/images/placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Merchant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  merchant.description ?? "",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                merchant.openHour != null
                    ? Row(
                      children: [
                        Text(
                          merchant.openHour!,
                          style: AppTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '-',
                            style: AppTheme.textTheme.labelMedium,
                          ),
                        ),
                        Text(
                          merchant.closeHour!,
                          style: AppTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
