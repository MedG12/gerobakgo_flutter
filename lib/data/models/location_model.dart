import 'package:flutter/material.dart';

class Location {
  final int id;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;

  Location({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    json['user_id'] =
        json['user_id'] is int ? json['user_id'] : int.parse(json['user_id']);
    return Location(
      id: json['user_id'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      lastUpdated: DateTime.parse(json['last_updated']).toLocal(),
    );
  }
}
