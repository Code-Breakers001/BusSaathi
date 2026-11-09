import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

const int kBusId = 1;
const int kRouteId = 1;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const BusSaathiApp());
}

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
  final SupabaseClient _db = Supabase.instance.client;

  List<LatLng> _routePoints = [];
  LatLng? _busPosition;
  DateTime? _busUpdatedAt;

  bool _driverMode = false; // true = this phone sends its GPS
  StreamSubscription<Position>? _gpsSub;
  Timer? _pollTimer;

  String _routeStatus = 'Loading route...';
  String _busStatus = 'Waiting for bus...';
  String _sendStatus = '';

  @override
  void initState() {
    super.initState();
    _loadRoute();
    _fetchBus();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchBus());
  }

  // ---------- Route ----------
  Future<void> _loadRoute() async {
    try {
      final row =
          await _db.from('routes').select().eq('id', kRouteId).single();
      var raw = row['path'];
      if (raw is String) raw = jsonDecode(raw);

      final points = <LatLng>[];
      if (raw is List) {
        for (final p in raw) {
          points.add(LatLng((p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble()));
        }
      }
      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _routeStatus = points.isEmpty
            ? 'Route has no points yet'
            : 'Route: ${row['name']} (${points.length} points)';
      });
      if (points.length >= 2) {
        _mapController.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(48),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _routeStatus = 'Route failed: $e');
    }
  }

  // ---------- Bus position (read) ----------
  Future<void> _fetchBus() async {
    try {
      final row = await _db
          .from('bus_positions')
          .select()
          .eq('bus_id', kBusId)
          .maybeSingle();
      if (row == null) {
        if (mounted) setState(() => _busStatus = 'No position for bus yet');
        return;
      }
      final pos = LatLng((row['lat'] as num).toDouble(),
          (row['lng'] as num).toDouble());
      final updated = DateTime.tryParse('${row['updated_at']}')?.toLocal();
      if (!mounted) return;
      setState(() {
        _busPosition = pos;
        _busUpdatedAt = updated;
        _busStatus = updated == null
            ? 'Bus seen'
            : 'Bus last seen ${_ago(updated)}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busStatus = 'Bus read failed: $e');
    }
  }

  String _ago(DateTime t) {
    final s = DateTime.now().difference(t).inSeconds;
    if (s < 60) return '${s < 0 ? 0 : s}s ago';
    if (s < 3600) return '${s ~/ 60} min ago';
    return '${s ~/ 3600} h ago';
  }

  // ---------- Driver mode (write) ----------
  Future<void> _setDriverMode(bool on) async {
    setState(() => _driverMode = on);
    if (!on) {
      await _gpsSub?.cancel();
      _gpsSub = null;
      setState(() => _sendStatus = '');
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        _driverMode = false;
        _sendStatus = 'Turn on Location (GPS) in phone settings';
      });
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _driverMode = false;
        _sendStatus = 'Location permission denied';
      });
      return;
    }

    setState(() => _sendStatus = 'Waiting for GPS...');
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_sendPosition);
  }

  Future<void> _sendPosition(Position p) async {
    try {
      await _db.from('bus_positions').upsert({
        'bus_id': kBusId,
        'lat': p.latitude,
        'lng': p.longitude,
        'speed': p.speed,
      }, onConflict: 'bus_id');
      if (!mounted) return;
      setState(() => _sendStatus =
          'Sent to server at ${TimeOfDay.now().format(context)}');
      _fetchBus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendStatus = 'Send failed: $e');
    }
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final statusLines = [
      _routeStatus,
      _busStatus,
      if (_sendStatus.isNotEmpty) _sendStatus,
    ].join('\n');

    return Scaffold(
      appBar: AppBar(
        title: const Text('BusSaathi'),
        actions: [
          const Center(child: Text('Driver')),
          Switch(value: _driverMode, onChanged: _setDriverMode),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(11.2588, 75.7804),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bussaathi',
              ),
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
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
            bottom: 8 + bottomInset,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              child: Text(statusLines,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}