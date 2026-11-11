import 'package:flutter/material.dart';
import '../data/bus_repository.dart';
import '../models/route_info.dart';
import 'route_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  late final Future<List<RouteInfo>> _routes;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _routes = repo.routes();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Routes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search route or destination',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RouteInfo>>(
              future: _routes,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Could not load routes.\n${snap.error}'),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final results = snap.data!
                    .where((r) =>
                        q.isEmpty ||
                        r.name.toLowerCase().contains(q) ||
                        r.destination.toLowerCase().contains(q))
                    .toList();
                if (results.isEmpty) {
                  return const Center(child: Text('No route found'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final r = results[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.alt_route),
                        title: Text(r.name),
                        subtitle: Text('To ${r.destination}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RouteDetailScreen(route: r),
                          ),
                        ),
                      ),
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
