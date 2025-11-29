import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  Position? _currentPosition;
  bool _isLocationEnabled = false;
  LocationPermission _permission = LocationPermission.denied;

  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  LocationPermission get permission => _permission;

  /// Initialize location service and check permissions
  Future<bool> initialize() async {
    try {
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isLocationEnabled) {
        return false;
      }

      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
        if (_permission == LocationPermission.denied) {
          return false;
        }
      }

      if (_permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error initializing location service: $e');
      return false;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      _permission = await Geolocator.requestPermission();
      return _permission;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Check if location permission is granted
  Future<bool> isPermissionGranted() async {
    _permission = await Geolocator.checkPermission();
    return _permission == LocationPermission.whileInUse ||
        _permission == LocationPermission.always;
  }

  /// Get current user position
  Future<Position?> getCurrentPosition() async {
    try {
      final initialized = await initialize();
      if (!initialized) {
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates
  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address string
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return locations.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to kilometers
  }

  /// Calculate distance from current position to a point
  double? calculateDistanceFromCurrent(double latitude, double longitude) {
    if (_currentPosition == null) return null;
    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Get distance in a user-friendly format
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.round()} km';
    }
  }

  /// Open device settings to enable location
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for location permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Stream position updates
  Stream<Position> getPositionStream({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Get last known position (faster than current position)
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }

  /// Calculate bearing between two points
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get direction text from bearing
  String getDirectionFromBearing(double bearing) {
    if (bearing >= -22.5 && bearing < 22.5) return 'North';
    if (bearing >= 22.5 && bearing < 67.5) return 'Northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'East';
    if (bearing >= 112.5 && bearing < 157.5) return 'Southeast';
    if (bearing >= 157.5 || bearing < -157.5) return 'South';
    if (bearing >= -157.5 && bearing < -112.5) return 'Southwest';
    if (bearing >= -112.5 && bearing < -67.5) return 'West';
    return 'Northwest';
  }
}
