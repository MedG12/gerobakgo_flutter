import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/data/models/merchant_model.dart';
import 'package:gerobakgo_with_api/helper/user_utils.dart';

Widget merchantMarker(Merchant merchant) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.blue, // Warna border
        width: 2.0, // Ketebalan border
      ),
      // Opsional: tambahkan boxShadow
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
        ),
      ],
    ),
    child: CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      backgroundImage:
          merchant.photoUrl != null
              ? NetworkImage(dotenv.env['STORAGE_URL']! + merchant.photoUrl!)
              : null,
      child:
          (merchant.photoUrl == null)
              ? Text(
                UserUtils.getInitials(merchant.name),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              )
              : null,
    ),
  );
}
