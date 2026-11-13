class Bus {
  final int id;
  final int routeId;
  final String busNumber;
  final String busFleet;
  final String colour;

  const Bus({
    required this.id,
    required this.routeId,
    required this.busNumber,
    required this.busFleet,
    required this.colour,
  });

  factory Bus.fromMap(Map<String, dynamic> m) => Bus(
        id: (m['id'] as num).toInt(),
        routeId: (m['route_id'] as num).toInt(),
        busNumber: (m['bus_number'] ?? '').toString(),
        busFleet: (m['bus_fleet'] ?? '').toString(),
        colour: (m['colour'] ?? '').toString(),
      );

  String get title => busFleet.isEmpty ? busNumber : '$busFleet - $busNumber';
}
