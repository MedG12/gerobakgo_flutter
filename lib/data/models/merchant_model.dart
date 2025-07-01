import 'package:gerobakgo_with_api/data/models/menu_model.dart';

class Merchant {
  int id;
  String name;
  String description;
  String? photoUrl;
  String? openHour;
  String? closeHour;
  List<Menu>? menus;

  Merchant({
    required this.id,
    required this.name,
    required this.description,
    this.photoUrl,
    this.openHour,
    this.closeHour,
    this.menus,
  });

  Merchant.fromJson(Map<String, dynamic> json)
    : id = json['merchant_id'],
      name = json['name'],
      description = json['description'],
      photoUrl = json['photoUrl'],
      openHour = json['openHour'],
      closeHour = json['closeHour'],
      menus =
          (json['menus'] as List?)
              ?.map((menu) => Menu.fromJson(menu as Map<String, dynamic>))
              .toList();

  Map<String, dynamic> toJson() {
    return {
      'menu_id': id,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'openHour': openHour,
      'closeHour': closeHour,
      'menus': menus?.map((menu) => menu.toJson()).toList(),
    };
  }

  factory Merchant.fromMap(Map<String, dynamic> map) {
    return Merchant(
      id: map['menu_id'],
      name: map['name'],
      description: map['description'],
      photoUrl: map['photoUrl'],
      openHour: map['openHour'],
      closeHour: map['closeHour'],
      menus:
          (map['menus'] as List?)
              ?.map((menu) => Menu.fromMap(menu as Map<String, dynamic>))
              .toList(),
    );
  }
}
