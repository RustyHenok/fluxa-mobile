import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.child,
    required this.currentLocation,
    super.key,
  });

  final Widget child;
  final String currentLocation;

  int _indexForLocation() {
    if (currentLocation.startsWith('/tasks')) {
      return 1;
    }
    if (currentLocation.startsWith('/exports')) {
      return 2;
    }
    if (currentLocation.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            label: 'Exports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              return;
            case 1:
              context.go('/tasks');
              return;
            case 2:
              context.go('/exports');
              return;
            case 3:
              context.go('/settings');
              return;
          }
        },
        selectedIndex: _indexForLocation(),
      ),
    );
  }
}
