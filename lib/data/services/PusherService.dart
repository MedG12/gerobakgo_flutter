import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gerobakgo_with_api/data/models/location_model.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final _stream = StreamController<Location>.broadcast();
  bool isInitialized = false;

  Stream<Location> get stream => _stream.stream;

  Future<void> intializePusher() async {
    try {
      if (isInitialized) return;

      await _pusher.init(
        apiKey: dotenv.env['PUSHER_APP_KEY']!,
        cluster: dotenv.env['PUSHER_APP_CLUSTER']!,
        onSubscriptionSucceeded: (String connection, dynamic e) {
          print('connected to pusher ${connection}');
        },
        onEvent: (event) {
          final Map<String, dynamic> data = jsonDecode(event.data);
          print(data['last_updated']);
          if (data != null) {
            try {
              _stream.add(Location.fromJson(data));
              print(data);
            } catch (e) {
              print(e);
            }
          }
        },
      );
      await _pusher.subscribe(channelName: 'live-locations');
      await _pusher.connect();

      isInitialized = true;
    } catch (e) {
      print("Pusher initialize error ${e}");
    }
  }

  static String getChannelName(String channel) {
    return channel;
  }
}
