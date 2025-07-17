// lib/core/utils/time_utils.dart

import 'package:flutter/material.dart';

class TimeUtils {
  /// Convert string (HH:mm) to TimeOfDay. Return null if invalid.
  static TimeOfDay? parseTimeString(String? timeString) {
    if (timeString == null) return null;

    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  /// Convert TimeOfDay to string (HH:mm).
  static String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
