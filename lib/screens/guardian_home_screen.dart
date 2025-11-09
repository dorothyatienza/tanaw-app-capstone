import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:tanaw_app/screens/profile_screen.dart';
import 'package:tanaw_app/screens/status_screen.dart';
import 'package:tanaw_app/state/guardian_mode_state.dart';
import 'package:tanaw_app/widgets/animated_bottom_nav_bar.dart';
import 'package:tanaw_app/widgets/app_logo.dart';
import 'package:tanaw_app/widgets/fade_page_route.dart';
import 'package:tanaw_app/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  GuardianHomeScreenState createState() => GuardianHomeScreenState();
}

class GuardianHomeScreenState extends State<GuardianHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final FlutterTts _flutterTts = FlutterTts();
  int _selectedIndex = 1;
  String? _expandedId;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          FadePageRoute(page: const StatusScreen()),
        );
        break;
      case 1:
        // Already on Guardian Home Screen
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          FadePageRoute(page: const ProfileScreen()),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102A43),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppLogo(
          isGuardianMode: Provider.of<GuardianModeState>(
            context,
          ).isGuardianModeEnabled,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_outlined, color: Colors.white),
            onPressed: () {
              _speak('Latest detections loaded from Firestore');
            },
            tooltip: 'Read Latest Record',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildDashboardSummary(),
            const SizedBox(height: 20),
            const Text(
              'GUARDIAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Latest Records',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildDetectionsStream()),
            _buildDeviceStatus(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF163C63),
        borderRadius: BorderRadius.circular(15),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseService.streamDetections(),
        builder: (context, snapshot) {
          // Calculate Last Detected and Total Records from Firestore data
          String lastDetectedText = 'No detections';
          String totalRecordsText = '0';

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final detections = snapshot.data!;

            // Total Records: count all detections
            totalRecordsText = detections.length.toString();

            // Last Detected: get the most recent detection (first in the list since it's ordered by timestamp descending)
            final mostRecent = detections.first;
            final timestamp = mostRecent['timestamp'] as Timestamp?;
            if (timestamp != null) {
              lastDetectedText = _formatTimeAgo(timestamp.toDate());
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            lastDetectedText = 'Loading...';
            totalRecordsText = '...';
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _DashboardItem(
                icon: Icons.location_on,
                title: 'Location',
                value: 'Active',
                tooltip: 'Location tracking is active and sharing.',
              ),
              _DashboardItem(
                icon: Icons.watch_later,
                title: 'Last Detected',
                value: lastDetectedText,
                tooltip: 'Time since the last object was detected.',
              ),
              _DashboardItem(
                icon: Icons.receipt_long,
                title: 'Total Records',
                value: totalRecordsText,
                tooltip: 'Total objects detected (all-time count).',
              ),
            ],
          );
        },
      ),
    );
  }

  /// Formats a DateTime to a human-readable "time ago" string.
  /// Returns format like "2 mins ago", "3 hours ago", "1 day ago".
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Calculate time difference in minutes, hours, and days
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    // Return the most appropriate unit (minutes, hours, or days)
    if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (minutes > 0) {
      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildDeviceStatus() {
    return Center(
      child: Column(
        children: [
          const Text(
            "User's Device Status:",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Chip(
            avatar: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            label: const Text('Connected'),
            backgroundColor: const Color(0xFF163C63),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionsStream() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.streamDetections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading detections: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No detections found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final detections = snapshot.data!;
        final groupedDetections = _groupDetectionsByDate(detections);

        return ListView.builder(
          itemCount: groupedDetections.length,
          itemBuilder: (context, index) {
            final group = groupedDetections[index];
            return _buildDetectionGroup(group['title'], group['detections']);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupDetectionsByDate(
    List<Map<String, dynamic>> detections,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(const Duration(days: 7));

    final Map<String, List<Map<String, dynamic>>> groups = {
      'TODAY': [],
      'YESTERDAY': [],
      'THIS WEEK': [],
      'OLDER': [],
    };

    for (final detection in detections) {
      final timestamp = detection['timestamp'] as Timestamp?;
      if (timestamp == null) continue;

      final detectionDate = timestamp.toDate();
      final detectionDay = DateTime(
        detectionDate.year,
        detectionDate.month,
        detectionDate.day,
      );

      if (detectionDay == today) {
        groups['TODAY']!.add(detection);
      } else if (detectionDay == yesterday) {
        groups['YESTERDAY']!.add(detection);
      } else if (detectionDate.isAfter(weekStart)) {
        groups['THIS WEEK']!.add(detection);
      } else {
        groups['OLDER']!.add(detection);
      }
    }

    return groups.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => {'title': entry.key, 'detections': entry.value})
        .toList();
  }

  Widget _buildDetectionGroup(
    String title,
    List<Map<String, dynamic>> detections,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...detections.map((detection) => _buildDetectionCard(detection)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetectionCard(Map<String, dynamic> detection) {
    final isExpanded = _expandedId == detection['id'];
    final icon = _mapStoredIconToIconData(detection);

    final Color cardColor = isExpanded ? Colors.white : const Color(0xFFD6E9F8);
    final Color textColor = const Color(0xFF173A5E);
    final Color subtitleColor = Colors.grey.shade600;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        key: ValueKey(detection['id']),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedId = expanded ? (detection['id'] as String?) : null;
          });
        },
        leading: Icon(icon, color: textColor, size: 32),
        title: Text(
          'Encountered: ${detection['type']}',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          detection['message'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
        trailing: Icon(Icons.expand_more, color: textColor),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detection['message'] ?? '',
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        detection['location'] ?? '',
                        style: TextStyle(
                          color: subtitleColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_outlined,
                      size: 14,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      detection['time'] ?? '',
                      style: TextStyle(color: subtitleColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _mapStoredIconToIconData(Map<String, dynamic> detection) {
    // Try to reconstruct IconData from stored properties
    if (detection['iconCodePoint'] != null) {
      return IconData(
        detection['iconCodePoint'],
        fontFamily: detection['iconFontFamily'],
        fontPackage: detection['iconFontPackage'],
        matchTextDirection: detection['iconMatchTextDirection'] ?? false,
      );
    }

    // Fallback to string-based icon mapping
    final iconString = detection['icon']?.toString() ?? '';
    switch (iconString) {
      case 'Icons.stairs_outlined':
        return Icons.stairs_outlined;
      case 'Icons.water_drop_outlined':
        return Icons.water_drop_outlined;
      case 'Icons.elevator_outlined':
        return Icons.elevator_outlined;
      case 'Icons.block_outlined':
        return Icons.block_outlined;
      case 'Icons.construction_outlined':
        return Icons.construction_outlined;
      case 'Icons.announcement_outlined':
        return Icons.announcement_outlined;
      case 'Icons.ramp_right_outlined':
        return Icons.ramp_right_outlined;
      case 'Icons.directions_walk_outlined':
        return Icons.directions_walk_outlined;
      case 'Icons.expand_less_outlined':
        return Icons.expand_less_outlined;
      case 'Icons.terrain_outlined':
        return Icons.terrain_outlined;
      case 'Icons.traffic_outlined':
        return Icons.traffic_outlined;
      case 'Icons.alt_route_outlined':
        return Icons.alt_route_outlined;
      default:
        return Icons.help_outline; // Neutral fallback
    }
  }
}

class _DashboardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String tooltip;

  const _DashboardItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
