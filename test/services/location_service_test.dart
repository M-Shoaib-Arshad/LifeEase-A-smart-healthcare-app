import 'package:flutter_test/flutter_test.dart';
import 'package:LifeEase/services/location_service.dart';

void main() {
  group('LocationService', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    group('Distance Calculation', () {
      test('calculateDistance returns correct distance between two points', () {
        // Test distance between New York City and Los Angeles
        // NYC: 40.7128, -74.0060
        // LA: 34.0522, -118.2437
        // Expected distance: approximately 3936 km
        final distance = locationService.calculateDistance(
          40.7128,
          -74.0060,
          34.0522,
          -118.2437,
        );

        // The distance should be approximately 3936 km (allow some tolerance)
        expect(distance, greaterThan(3900));
        expect(distance, lessThan(4000));
      });

      test('calculateDistance returns 0 for same point', () {
        final distance = locationService.calculateDistance(
          40.7128,
          -74.0060,
          40.7128,
          -74.0060,
        );

        expect(distance, equals(0.0));
      });

      test('calculateDistance handles negative coordinates', () {
        // Test with southern hemisphere coordinates
        // Sydney: -33.8688, 151.2093
        // Melbourne: -37.8136, 144.9631
        final distance = locationService.calculateDistance(
          -33.8688,
          151.2093,
          -37.8136,
          144.9631,
        );

        // Distance should be approximately 713 km
        expect(distance, greaterThan(700));
        expect(distance, lessThan(750));
      });
    });

    group('Format Distance', () {
      test('formatDistance returns meters for distances less than 1 km', () {
        final result = locationService.formatDistance(0.5);
        expect(result, equals('500 m'));
      });

      test('formatDistance returns km with decimal for distances less than 10 km', () {
        final result = locationService.formatDistance(5.5);
        expect(result, equals('5.5 km'));
      });

      test('formatDistance returns whole km for distances 10 km or more', () {
        final result = locationService.formatDistance(15.7);
        expect(result, equals('16 km'));
      });

      test('formatDistance handles zero distance', () {
        final result = locationService.formatDistance(0);
        expect(result, equals('0 m'));
      });
    });

    group('Bearing Calculation', () {
      test('calculateBearing returns correct bearing', () {
        // Bearing from NYC to LA should be approximately 273 degrees (west)
        final bearing = locationService.calculateBearing(
          40.7128,
          -74.0060,
          34.0522,
          -118.2437,
        );

        // The bearing should be approximately 273 degrees
        expect(bearing, greaterThan(260));
        expect(bearing, lessThan(280));
      });

      test('getDirectionFromBearing returns North for 0 degrees', () {
        final direction = locationService.getDirectionFromBearing(0);
        expect(direction, equals('North'));
      });

      test('getDirectionFromBearing returns East for 90 degrees', () {
        final direction = locationService.getDirectionFromBearing(90);
        expect(direction, equals('East'));
      });

      test('getDirectionFromBearing returns South for 180 degrees', () {
        final direction = locationService.getDirectionFromBearing(180);
        expect(direction, equals('South'));
      });

      test('getDirectionFromBearing returns West for -90 degrees', () {
        final direction = locationService.getDirectionFromBearing(-90);
        expect(direction, equals('West'));
      });

      test('getDirectionFromBearing returns Northeast for 45 degrees', () {
        final direction = locationService.getDirectionFromBearing(45);
        expect(direction, equals('Northeast'));
      });
    });

    group('Current Position', () {
      test('currentPosition is null initially', () {
        expect(locationService.currentPosition, isNull);
      });

      test('calculateDistanceFromCurrent returns null when no current position', () {
        final result = locationService.calculateDistanceFromCurrent(40.7128, -74.0060);
        expect(result, isNull);
      });
    });

    group('Singleton Pattern', () {
      test('LocationService returns same instance', () {
        final instance1 = LocationService();
        final instance2 = LocationService();
        expect(identical(instance1, instance2), isTrue);
      });
    });
  });
}
