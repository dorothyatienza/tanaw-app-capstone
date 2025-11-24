import 'dart:math';

import 'package:flutter/material.dart';

// A constant list of mock objects representing various reported obstacles/events.
const List<Map<String, dynamic>> mockObjects = [
  {
    'type': 'WHITEBOARD',
    'message': 'Whiteboard spotted. Area is accessible.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.border_color_outlined,
  },
  {
    'type': 'TRASH BIN',
    'message': 'Trash bin located. Area appears clear.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.delete_outline,
  },
  {
    'type': 'WATER DISPENSER',
    'message': 'Water dispenser available nearby.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.water_outlined,
  },
  {
    'type': 'FIRE EXTINGUISHER',
    'message': 'Fire extinguisher located. Emergency access clear.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.local_fire_department_outlined,
  },
  {
    'type': 'DIRECTIONAL SIGN',
    'message': 'Directional sign detected for navigation.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.arrow_forward_outlined,
  },
  {
    'type': 'BENCH',
    'message': 'Bench available for seating.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.event_seat_outlined,
  },
  {
    'type': 'LOCKER',
    'message': 'Lockers detected along the hallway.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.lock_outline,
  },
  {
    'type': 'BOOKSHELF',
    'message': 'Bookshelf located. Library section nearby.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.menu_book_outlined,
  },
  {
    'type': 'EXIT SIGN',
    'message': 'Exit sign detected for safe routing.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.exit_to_app_outlined,
  },
  {
    'type': 'INFO KIOSK',
    'message': 'Information kiosk available for assistance.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.info_outline,
  },
  {
    'type': 'BICYCLE RACK',
    'message': 'Bicycle rack detected near entrance.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.directions_bike_outlined,
  },
  {
    'type': 'LAMP POST',
    'message': 'Lamp post identified. Lighting adequate.',
    'location': '- Brgy. Alangilan, Batangas City',
    'icon': Icons.light_outlined,
  },
];

/// Returns a new Map copied from a randomly selected entry in [mockObjects].
Map<String, dynamic> pickRandomObject() {
  final int index = Random().nextInt(mockObjects.length);
  return Map<String, dynamic>.from(mockObjects[index]);
}
