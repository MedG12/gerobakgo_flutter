import 'dart:convert';

import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:gerobakgo_with_api/data/models/menu_model.dart';

class Merchant {
  int id;
  String name;
  int? userId;
  String? description;
  String? photoUrl;
  String? openHour;
  String? closeHour;
  Location? location;
  List<Menu>? menus;

  Merchant({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    this.photoUrl,
    this.openHour,
    this.closeHour,
    this.menus,
    this.location,
  });

  // Gunakan factory constructor
  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['merchant_id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      openHour: json['openHour'],
      closeHour: json['closeHour'],
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      menus:
          json['menus'] != null
              ? (json['menus'] as List)
                  .map((menu) => Menu.fromJson(menu))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': id,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'openHour': openHour,
      'closeHour': closeHour,
      'menus': menus, 
    };
  }

  // Jika fromMap tidak diperlukan, bisa dihapus
  factory Merchant.fromMap(Map<String, dynamic> map) {
    return Merchant(
      id: map['merchant_id'],
      name: map['name'],
      description: map['description'],
      photoUrl: map['photoUrl'],
      openHour: map['openHour'],
      closeHour: map['closeHour'],
      menus: map['menus'],
    );
  }
}
