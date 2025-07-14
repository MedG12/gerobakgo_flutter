class Menu {
  final int? id;
  final String? photoUrl;
  final int? merchantId;
  final String name;
  final String description;
  final String price;

  Menu({
    this.id,
    this.merchantId,
    this.photoUrl,
    required this.name,
    required this.description,
    required this.price,
  });

  Menu copyWith({
    int? id,
    int? merchantId,
    String? name,
    String? description,
    String? price,
    String? photoUrl,
    // Tambahkan parameter lainnya
  }) {
    return Menu(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      // Tambahkan field lainnya
    );
  }

  // Factory constructor to create a Menu instance from JSON
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['menu_id'],
      merchantId: json['merchant_id'],
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
      'merchantId': merchantId,
      'photoUrl': photoUrl,
      'name': name,
      'description': description,
      'price': price,
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['data']['menu_id'],
      merchantId: map['data']['merchantId'],
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
