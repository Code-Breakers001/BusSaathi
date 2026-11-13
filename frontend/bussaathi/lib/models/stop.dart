class Stop {
  final int id;
  final int routeId;
  final String name;
  final String landmark;
  final double lat;
  final double lng;
  final int order;

  const Stop({
    required this.id,
    required this.routeId,
    required this.name,
    required this.landmark,
    required this.lat,
    required this.lng,
    required this.order,
  });

  factory Stop.fromMap(Map<String, dynamic> m) => Stop(
        id: (m['id'] as num).toInt(),
        routeId: (m['route_id'] as num).toInt(),
        name: (m['name'] ?? '').toString(),
        landmark: (m['landmark'] ?? '').toString(),
        lat: (m['lat'] as num?)?.toDouble() ?? 0,
        lng: (m['lng'] as num?)?.toDouble() ?? 0,
        order: (m['stop_order'] as num?)?.toInt() ?? 0,
      );
}
