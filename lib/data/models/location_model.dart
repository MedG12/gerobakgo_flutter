import 'package:flutter/material.dart';

class Location {
  final int id;
  final double? latitude;
  final double? longitude;
  final DateTime lastUpdated;

  Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    print(json['latitude'].runtimeType);
    json['user_id'] =
        json['user_id'] is int ? json['user_id'] : int.parse(json['user_id']);
    return Location(
      id: json['user_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastUpdated: DateTime.parse(json['last_updated']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'latitude': latitude,
      'longitude': longitude,
      'last_updated': lastUpdated.toString(),
    };
  }
}
