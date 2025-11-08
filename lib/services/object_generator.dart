import 'dart:math';

import 'package:flutter/material.dart';

// A constant list of mock objects representing various reported obstacles/events.
const List<Map<String, dynamic>> mockObjects = [
  {
    'type': 'STAIRS',
    'message': 'The designated team based on your report will be there soon.',
    'location': '- Maharlika Highway, Sto. Tomas City, Batangas 4234',
    'icon': Icons.stairs_outlined,
  },
  {
    'type': 'WET_FLOOR',
    'message': 'Maintenance has been notified to address the wet surface.',
    'location': '- P. Burgos Street, Batangas City 4200',
    'icon': Icons.water_drop_outlined,
  },
  {
    'type': 'ELEVATOR_OUT',
    'message':
        'Elevator is temporarily unavailable. Use nearby stairs or ramp.',
    'location': '- SM City Batangas, Level 2, Service Area',
    'icon': Icons.elevator_outlined,
  },
  {
    'type': 'OBSTRUCTION',
    'message': 'Road obstruction reported. Teams are on their way.',
    'location': '- JP Laurel Highway, Tanauan City 4232',
    'icon': Icons.block_outlined,
  },
  {
    'type': 'CONSTRUCTION',
    'message': 'Active construction zone. Expect partial closures.',
    'location': '- National Rd., San Jose, Batangas 4227',
    'icon': Icons.construction_outlined,
  },
  {
    'type': 'CLOSED_ROAD',
    'message': 'Road temporarily closed. Follow marked detour.',
    'location': '- Padre Burgos St., Lipa City 4217',
    'icon': Icons.announcement_outlined,
  },
  {
    'type': 'RAMP',
    'message': 'Temporary ramp installed for accessibility.',
    'location': '- Bauan–Batangas Rd., Bauan 4201',
    'icon': Icons.ramp_right_outlined,
  },
  {
    'type': 'CROSSWALK',
    'message': 'Crosswalk repaint scheduled this week.',
    'location': '- Ayala Hwy., Lipa City 4217',
    'icon': Icons.directions_walk_outlined,
  },
  {
    'type': 'LOW_CLEARANCE',
    'message': 'Low ceiling ahead. Proceed with caution.',
    'location': '- Lemery Public Market, Basement Access',
    'icon': Icons.expand_less_outlined,
  },
  {
    'type': 'LOOSE_GRAVEL',
    'message': 'Loose gravel reported. Slippery when wet.',
    'location': '- Taysan Rd., Rosario, Batangas 4225',
    'icon': Icons.terrain_outlined,
  },
  {
    'type': 'TRAFFIC',
    'message': 'Heavy traffic reported. Expect delays.',
    'location': '- STAR Tollway, Balete Exit',
    'icon': Icons.traffic_outlined,
  },
  {
    'type': 'DETOUR',
    'message': 'Detour in effect. Follow signage for alternate route.',
    'location': '- Calaca–Lemery Rd., Diversion',
    'icon': Icons.alt_route_outlined,
  },
];

/// Returns a new Map copied from a randomly selected entry in [mockObjects].
Map<String, dynamic> pickRandomObject() {
  final int index = Random().nextInt(mockObjects.length);
  return Map<String, dynamic>.from(mockObjects[index]);
}
