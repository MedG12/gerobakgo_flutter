import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/core/view_models/auth_viewmodel.dart';
import 'package:gerobakgo_with_api/helper/user_utils.dart';
import 'package:provider/provider.dart';

Widget navItemProfile(context, bool isActive) {
  final authViewModel = Provider.of<AuthViewmodel>(context);
  final user = authViewModel.currentUser;
  
  if(user == null) return Icon(Icons.person);

  return Container(
    decoration:
        isActive
            ? BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              shape: BoxShape.circle,
            )
            : null,
    child:
        user.photoUrl != null
            ? CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                dotenv.env['STORAGE_URL']! + user.photoUrl!,
              ),
            )
            : CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueAccent,
              child: Text(
                UserUtils.getInitials(user.name),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
  );
}
