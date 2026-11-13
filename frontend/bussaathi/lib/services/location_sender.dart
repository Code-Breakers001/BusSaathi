import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Sends this phone's GPS to bus_positions for one bus.
/// The Driver screen calls start(busId) and stop().
class LocationSender {
  StreamSubscription<Position>? _sub;
  bool get running => _sub != null;

  /// Returns null when started, or a message to show the driver.
  Future<String?> start(int busId, {void Function(String)? onStatus}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Turn on Location (GPS) in phone settings';
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return 'Location permission denied';
    }

    await WakelockPlus.enable(); // keep the screen on (charging mount)
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((p) async {
      try {
        await Supabase.instance.client.from('bus_positions').upsert({
          'bus_id': busId,
          'lat': p.latitude,
          'lng': p.longitude,
          'speed': p.speed,
        }, onConflict: 'bus_id');
        onStatus?.call('Sent');
      } catch (e) {
        onStatus?.call('Send failed: $e');
      }
    });
    return null;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await WakelockPlus.disable();
  }
}