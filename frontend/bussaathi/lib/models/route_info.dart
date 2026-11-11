class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);
}

class RouteInfo {
  final int id;
  final String name;
  final String destination;
  final List<GeoPoint> path;

  const RouteInfo({
    required this.id,
    required this.name,
    required this.destination,
    required this.path,
  });

  factory RouteInfo.fromMap(Map<String, dynamic> m) {
    final raw = m['path'];
    final points = <GeoPoint>[];
    if (raw is List) {
      for (final p in raw) {
        if (p is Map) {
          points.add(GeoPoint(
            (p['lat'] as num).toDouble(),
            (p['lng'] as num).toDouble(),
          ));
        }
      }
    }
    return RouteInfo(
      id: (m['id'] as num).toInt(),
      name: (m['name'] ?? '').toString(),
      destination: (m['destination'] ?? '').toString(),
      path: points,
    );
  }
}
