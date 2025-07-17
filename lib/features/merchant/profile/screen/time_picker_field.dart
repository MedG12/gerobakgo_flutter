import 'package:flutter/material.dart';
import 'package:gerobakgo_with_api/helper/time_utils.dart';

Widget timePickerField(
  String label,
  TimeOfDay? time,
  String placeholder,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5D42D1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        time != null ? TimeUtils.formatTimeOfDay(time) : placeholder,
        style: TextStyle(color: time != null ? Colors.black : Colors.grey),
      ),
    ),
  );
}
