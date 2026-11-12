import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gets the device location once permission is granted and keeps a local
/// coordinate cache so prayer calculations can continue without internet.
class AwwabLocationService {
  static const _latKey = 'awwab_location_lat';
  static const _lonKey = 'awwab_location_lon';

  Future<Position?> getLocation({bool askPermission = true}) async {
    final prefs = await SharedPreferences.getInstance();
    Position? cached;
    final lat = prefs.getDouble(_latKey);
    final lon = prefs.getDouble(_lonKey);
    if (lat != null && lon != null) {
      cached = Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }

    if (!await Geolocator.isLocationServiceEnabled()) return cached;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && askPermission) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return cached;
    }

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        await _save(prefs, lastKnown);
        cached = lastKnown;
      }
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 18),
        ),
      );
      await _save(prefs, current);
      return current;
    } catch (_) {
      // GPS may take longer indoors or be unavailable. The last verified
      // device position remains usable for offline prayer-time calculation.
      return cached;
    }
  }

  Future<void> _save(SharedPreferences prefs, Position position) async {
    await prefs.setDouble(_latKey, position.latitude);
    await prefs.setDouble(_lonKey, position.longitude);
  }
}
