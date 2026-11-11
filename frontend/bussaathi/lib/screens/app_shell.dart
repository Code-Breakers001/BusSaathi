import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'routes_screen.dart';
import 'waiting_screen.dart';
import 'driver_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _i = 0;
  final _pages = const [
    HomeScreen(),
    RoutesScreen(),
    WaitingScreen(),
    DriverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _i, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (i) => setState(() => _i = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.directions_bus), label: 'Buses'),
          NavigationDestination(icon: Icon(Icons.alt_route), label: 'Routes'),
          NavigationDestination(icon: Icon(Icons.push_pin), label: 'Waiting'),
          NavigationDestination(icon: Icon(Icons.drive_eta), label: 'Driver'),
        ],
      ),
    );
  }
}
