class BusPosition {
  final int busId;
  final double lat;
  final double lng;
  final double? speed;
  final DateTime? updatedAt;

  const BusPosition({
    required this.busId,
    required this.lat,
    required this.lng,
    this.speed,
    this.updatedAt,
  });

  factory BusPosition.fromMap(Map<String, dynamic> m) => BusPosition(
        busId: (m['bus_id'] as num).toInt(),
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        speed: (m['speed'] as num?)?.toDouble(),
        updatedAt: m['updated_at'] == null
            ? null
            : DateTime.parse(m['updated_at'].toString()),
      );

  // Live = updated in the last 30 seconds, Last seen = last 10 minutes,
  // otherwise No info. Change these two numbers if the team agrees on others.
  String get status {
    final t = updatedAt;
    if (t == null) return 'No info';
    final s = DateTime.now().difference(t).inSeconds;
    if (s <= 30) return 'Live';
    if (s <= 600) return 'Last seen';
    return 'No info';
  }

  String get ageText {
    final t = updatedAt;
    if (t == null) return 'No update time';
    final s = DateTime.now().difference(t).inSeconds;
    if (s < 10) return 'Updated just now';
    if (s < 60) return 'Updated $s sec ago';
    if (s < 3600) return 'Updated ${s ~/ 60} min ago';
    return 'Updated ${s ~/ 3600} h ago';
  }
}
