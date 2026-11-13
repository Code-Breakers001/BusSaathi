import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum BusStatus { live, lastSeen, noInfo }

class BusMarkerData {
  final int busId;
  final String label;
  final LatLng position;
  final BusStatus status;

  const BusMarkerData({
    required this.busId,
    required this.label,
    required this.position,
    required this.status,
  });
}

class BusMap extends StatefulWidget {
  final List<LatLng> routePath;
  final List<BusMarkerData> buses;
  final LatLng? waitingPin;
  final void Function(LatLng point)? onMapTap;

  const BusMap({
    super.key,
    this.routePath = const [],
    this.buses = const [],
    this.waitingPin,
    this.onMapTap,
  });

  @override
  State<BusMap> createState() => _BusMapState();
}

class _BusMapState extends State<BusMap> {
  final MapController _controller = MapController();

  @override
  void didUpdateWidget(covariant BusMap old) {
    super.didUpdateWidget(old);
    if (widget.routePath.length != old.routePath.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }
  }

  void _fit() {
    if (widget.routePath.length < 2) return;
    _controller.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(widget.routePath),
      padding: const EdgeInsets.all(48),
    ));
  }

  Color _colour(BusStatus s) {
    switch (s) {
      case BusStatus.live:
        return Colors.green;
      case BusStatus.lastSeen:
        return Colors.orange;
      case BusStatus.noInfo:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRoute = widget.routePath.length >= 2;
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter:
            hasRoute ? widget.routePath.first : const LatLng(11.2588, 75.7804),
        initialZoom: 13,
        initialCameraFit: hasRoute
            ? CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(widget.routePath),
                padding: const EdgeInsets.all(48),
              )
            : null,
        onTap: widget.onMapTap == null
            ? null
            : (tapPos, point) => widget.onMapTap!(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.bussaathi',
        ),
        if (hasRoute)
          PolylineLayer(polylines: [
            Polyline(
                points: widget.routePath, strokeWidth: 5, color: Colors.blue),
          ]),
        if (widget.waitingPin != null)
          MarkerLayer(markers: [
            Marker(
              point: widget.waitingPin!,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_pin,
                  color: Colors.purple, size: 38),
            ),
          ]),
        MarkerLayer(
          markers: [
            for (final b in widget.buses)
              Marker(
                point: b.position,
                width: 44,
                height: 44,
                child: Icon(Icons.directions_bus,
                    color: _colour(b.status), size: 36),
              ),
          ],
        ),
      ],
    );
  }
}