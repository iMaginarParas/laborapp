import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Utility service for device location and reverse geocoding.
class LocationService {
  /// Returns the device's current [Position].
  ///
  /// Throws a [String] error message if location services are disabled
  /// or permissions are denied.
  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled. Please enable them in settings.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied. '
        'Please enable them in your device settings.',
      );
    }

    return Geolocator.getCurrentPosition();
  }

  /// Reverse-geocodes [position] into a human-readable address string.
  ///
  /// Returns `null` if the lookup fails or returns no results.
  Future<String?> getAddressFromLatLng(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = [
        place.name,
        place.subLocality,
        place.locality,
        place.postalCode,
        place.administrativeArea,
      ].where((p) => p != null && p.isNotEmpty).join(', ');

      return parts.isEmpty ? null : parts;
    } catch (_) {
      return null;
    }
  }
}
