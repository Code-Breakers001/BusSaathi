import 'package:flutter/material.dart';
import '../data/bus_repository.dart';
import '../models/bus.dart';
import '../models/route_info.dart';
import '../models/stop.dart';

class _RouteData {
  final List<Stop> stops;
  final List<Bus> buses;
  _RouteData(this.stops, this.buses);
}

class RouteDetailScreen extends StatefulWidget {
  final RouteInfo route;
  const RouteDetailScreen({super.key, required this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late final Future<_RouteData> _data;

  Future<_RouteData> _load() async {
    final stops = await repo.stops(widget.route.id);
    final buses = await repo.busesOnRoute(widget.route.id);
    return _RouteData(stops, buses);
  }

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: Text(widget.route.name)),
      body: FutureBuilder<_RouteData>(
        future: _data,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Could not load route.\n${snap.error}'),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('To ${widget.route.destination}', style: titleStyle),
              const SizedBox(height: 16),
              Text('Buses on this route', style: titleStyle),
              if (d.buses.isEmpty) const Text('No buses on this route yet'),
              for (final b in d.buses)
                ListTile(
                  leading: const Icon(Icons.directions_bus),
                  title: Text(b.title),
                  subtitle: b.colour.isEmpty ? null : Text(b.colour),
                ),
              const SizedBox(height: 16),
              Text('Stops', style: titleStyle),
              if (d.stops.isEmpty) const Text('No stops yet'),
              for (var i = 0; i < d.stops.length; i++)
                ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(d.stops[i].name),
                  subtitle: d.stops[i].landmark.isEmpty
                      ? null
                      : Text(d.stops[i].landmark),
                ),
            ],
          );
        },
      ),
    );
  }
}
