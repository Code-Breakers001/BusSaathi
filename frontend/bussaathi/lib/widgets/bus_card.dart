import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../models/bus_position.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  final String routeName;
  final BusPosition? position;
  final VoidCallback? onTap;

  const BusCard({
    super.key,
    required this.bus,
    required this.routeName,
    this.position,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Arrival time range will be added here when the server /eta is ready.
    final status = position?.status ?? 'No info';
    final line = position?.ageText ?? 'No position yet';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.directions_bus),
        title: Text(bus.title),
        subtitle: Text('$routeName\n$line'),
        isThreeLine: true,
        trailing: Chip(label: Text(status)),
      ),
    );
  }
}
