import 'package:flutter/material.dart';
import '../data/fake_data.dart';
import '../models/driver_models.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final List<LostItem> _items = makeLostItems();
  bool _breakdown = false;

  Future<void> _askBreakdown() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report breakdown?'),
        content: const Text('The bus will be marked as broken down.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, report'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (yes == true) setState(() => _breakdown = true);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Driver')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_breakdown)
            Card(
              color: Colors.red.shade100,
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Breakdown reported',
                    style: TextStyle(color: Colors.black87)),
                subtitle: const Text('Demo: not sent to the server yet',
                    style: TextStyle(color: Colors.black87)),
                trailing: TextButton(
                  onPressed: () => setState(() => _breakdown = false),
                  child: const Text('Clear'),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: _askBreakdown,
              icon: const Icon(Icons.build),
              label: const Text('Breakdown'),
            ),
          ),
          const SizedBox(height: 20),
          Text('Riders waiting ahead', style: titleStyle),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final p in fakePinsAhead)
                  ListTile(
                    leading: const Icon(Icons.push_pin),
                    title: Text(p.stop),
                    trailing: Text('${p.count} waiting'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Lost item reports', style: titleStyle),
          const SizedBox(height: 8),
          for (final item in _items)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description),
                    const SizedBox(height: 4),
                    Text('Status: ${item.status}'),
                    if (item.status == 'Reported') ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        FilledButton(
                          onPressed: () =>
                              setState(() => item.status = 'Found'),
                          child: const Text('Found'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              setState(() => item.status = 'Not found'),
                          child: const Text('Not found'),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
