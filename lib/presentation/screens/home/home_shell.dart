import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../discover/discover_screen.dart';
import '../scan/scan_screen.dart';
import '../video_feed/video_feed_screen.dart';
import '../daily_record/daily_record_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    DiscoverScreen(),
    ScanScreen(),
    VideoFeedScreen(),
    DailyRecordScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        indicatorColor: AppTheme.primary.withValues(alpha: 0.15),
        onDestinationSelected: (i) {
          if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScanScreen()),
            );
            return;
          }
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.camera_alt_outlined), selectedIcon: Icon(Icons.camera_alt), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Videos'),
          NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Log'),
        ],
      ),
    );
  }
}
