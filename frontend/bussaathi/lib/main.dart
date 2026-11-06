import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(const BusSaathiApp());

class BusSaathiApp extends StatelessWidget {
  const BusSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _sub;
  LatLng? _busPosition;
  String _status = 'Starting...';

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      setState(() => _status = 'Turn on Location (GPS) in phone settings');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _status = 'Location permission denied');
      return;
    }

    setState(() => _status = 'Waiting for GPS...');

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position p) {
      final point = LatLng(p.latitude, p.longitude);
      setState(() {
        _busPosition = point;
        _status = 'Live: ${p.latitude.toStringAsFixed(5)}, '
            '${p.longitude.toStringAsFixed(5)}';
      });
      _mapController.move(point, 16);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BusSaathi Map')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(9.9312, 76.2673),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bussaathi',
              ),
              if (_busPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _busPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.directions_bus,
                          color: Colors.red, size: 36),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              child: Text(_status,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}