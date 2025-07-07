class Menu {
  final int id;
  final String? photoUrl;
  final String name;
  final String description;
  final String price;

  Menu({
    required this.id,
    this.photoUrl,
    required this.name,
    required this.description,
    required this.price,
  });

  // Factory constructor to create a Menu instance from JSON
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['menu_id'],
      photoUrl: json['photoUrl'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
    );
  }

  // Factory constructor to create a Menu instance from a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'name': name,
      'description': description,
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['data']['menu_id'],
      name: map['data']['name'],
      photoUrl: map['data']['photoUrl'],
      description: map['data']['description'],
      price: map['data']['price'] ?? '0', // Default price if not provided
    );
  }

  static List<Menu> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Menu.fromJson(json)).toList();
  }
}
