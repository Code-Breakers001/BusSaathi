import 'dart:async';
import 'package:flutter/material.dart';
import '../data/bus_repository.dart';
import '../models/bus.dart';
import '../models/bus_position.dart';
import '../models/route_info.dart';
import '../widgets/bus_card.dart';
import 'route_detail_screen.dart';

class _HomeData {
  final List<Bus> buses;
  final List<RouteInfo> routes;
  _HomeData(this.buses, this.routes);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<_HomeData> _data;
  late final Stream<List<BusPosition>> _positions;
  Timer? _tick;

  Future<_HomeData> _load() async {
    final buses = await repo.buses();
    final routes = await repo.routes();
    return _HomeData(buses, routes);
  }

  @override
  void initState() {
    super.initState();
    _data = _load();
    _positions = repo.positions();
    // Re-check Live / Last seen labels every 10 seconds
    _tick = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('BusSaathi')),
      body: Column(
        children: [
          // Replace this box with Albin's map widget
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              "Map goes here (Albin's map)",
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
          Expanded(
            child: FutureBuilder<_HomeData>(
              future: _data,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Could not load buses.\n${snap.error}'),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final buses = snap.data!.buses;
                final routesById = {for (final r in snap.data!.routes) r.id: r};
                if (buses.isEmpty) {
                  return const Center(child: Text('No buses yet'));
                }
                return StreamBuilder<List<BusPosition>>(
                  stream: _positions,
                  builder: (context, ps) {
                    final pos = {
                      for (final p in ps.data ?? <BusPosition>[]) p.busId: p
                    };
                    return ListView.builder(
                      itemCount: buses.length,
                      itemBuilder: (context, i) {
                        final bus = buses[i];
                        final route = routesById[bus.routeId];
                        return BusCard(
                          bus: bus,
                          routeName: route?.name ?? 'Route ${bus.routeId}',
                          position: pos[bus.id],
                          onTap: route == null
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RouteDetailScreen(route: route),
                                    ),
                                  ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
