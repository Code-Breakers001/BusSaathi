import 'package:flutter/material.dart';
import '../data/bus_repository.dart';
import '../models/route_info.dart';
import '../models/stop.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late final Future<List<RouteInfo>> _routes;
  RouteInfo? _route;
  Future<List<Stop>>? _stops;
  Stop? _stop;
  int _stopIndex = 0;
  double _walk = 5;
  bool _pinned = false;
  bool _alerted = false;
  int _min = 0;
  int _max = 0;

  @override
  void initState() {
    super.initState();
    _routes = repo.routes();
  }

  void _pickRoute(RouteInfo r) {
    setState(() {
      _route = r;
      _stop = null;
      _stops = repo.stops(r.id);
    });
  }

  // Demo ETA until the server /eta is ready
  void _pin() {
    if (_stop == null) return;
    setState(() {
      _pinned = true;
      _alerted = false;
      _min = 2 + 4 * _stopIndex;
      _max = _min + 3;
    });
    _checkLeaveNow();
  }

  void _unpin() => setState(() => _pinned = false);

  void _closer() {
    setState(() {
      _min = (_min - 2).clamp(0, 99).toInt();
      _max = (_max - 2).clamp(0, 99).toInt();
    });
    _checkLeaveNow();
  }

  void _checkLeaveNow() {
    if (_pinned && !_alerted && _min <= _walk) {
      _alerted = true;
      final stopName = _stop?.name ?? 'your stop';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.notifications_active),
            title: const Text('Leave now'),
            content: Text(
              'Your bus may reach $stopName in $_min-$_max min. '
              'You need about ${_walk.round()} min to walk.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final leaveNow = _pinned && _min <= _walk;
    return Scaffold(
      appBar: AppBar(title: const Text("I'm waiting here")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pick your route', style: titleStyle),
          const SizedBox(height: 8),
          FutureBuilder<List<RouteInfo>>(
            future: _routes,
            builder: (context, snap) {
              if (snap.hasError) {
                return Text('Could not load routes.\n${snap.error}');
              }
              if (!snap.hasData) return const LinearProgressIndicator();
              return Wrap(
                spacing: 8,
                children: [
                  for (final r in snap.data!)
                    ChoiceChip(
                      label: Text(r.name),
                      selected: _route?.id == r.id,
                      onSelected: _pinned ? null : (_) => _pickRoute(r),
                    ),
                ],
              );
            },
          ),
          if (_stops != null) ...[
            const SizedBox(height: 16),
            Text('Pick your stop', style: titleStyle),
            const SizedBox(height: 8),
            FutureBuilder<List<Stop>>(
              future: _stops,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text('Could not load stops.\n${snap.error}');
                }
                if (!snap.hasData) return const LinearProgressIndicator();
                final stops = snap.data!;
                if (stops.isEmpty) return const Text('No stops on this route yet');
                return Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < stops.length; i++)
                      ChoiceChip(
                        label: Text(stops[i].name),
                        selected: _stop?.id == stops[i].id,
                        onSelected: _pinned
                            ? null
                            : (_) => setState(() {
                                  _stop = stops[i];
                                  _stopIndex = i;
                                }),
                      ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 16),
          Text('Minutes to walk to the stop: ${_walk.round()}'),
          Slider(
            value: _walk,
            min: 1,
            max: 30,
            divisions: 29,
            label: '${_walk.round()} min',
            onChanged: (v) {
              setState(() => _walk = v);
              _checkLeaveNow();
            },
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _pinned ? _unpin : (_stop == null ? null : _pin),
            icon: Icon(_pinned ? Icons.close : Icons.push_pin),
            label: Text(_pinned ? 'Remove my pin' : "I'm waiting here"),
          ),
          if (_pinned) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bus reaches ${_stop?.name ?? 'your stop'} in $_min-$_max min',
                        style: titleStyle),
                    const SizedBox(height: 4),
                    const Text('Demo times until the server /eta is ready.'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _closer,
                      child: const Text('Demo: bus gets closer'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (leaveNow) ...[
            const SizedBox(height: 12),
            Card(
              color: Colors.orange.shade100,
              child: const ListTile(
                leading: Icon(Icons.directions_walk, color: Colors.deepOrange),
                title: Text('Leave now',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.bold)),
                subtitle: Text('Your bus is close to your stop.',
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
