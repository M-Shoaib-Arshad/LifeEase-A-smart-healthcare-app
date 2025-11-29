import 'package:flutter_test/flutter_test.dart';
import 'package:LifeEase/models/push_notification.dart';

void main() {
  group('PushNotification', () {
    test('creates from map correctly', () {
      final map = {
        'id': 'test-id-123',
        'title': 'Test Notification',
        'body': 'This is a test notification body',
        'imageUrl': 'https://example.com/image.png',
        'data': {'key': 'value'},
        'receivedAt': '2024-01-01T12:00:00.000Z',
        'type': 'appointment_reminder',
      };

      final notification = PushNotification.fromMap(map);

      expect(notification.id, 'test-id-123');
      expect(notification.title, 'Test Notification');
      expect(notification.body, 'This is a test notification body');
      expect(notification.imageUrl, 'https://example.com/image.png');
      expect(notification.data, {'key': 'value'});
      expect(notification.type, PushNotificationType.appointmentReminder);
    });

    test('converts to map correctly', () {
      final notification = PushNotification(
        id: 'test-id-456',
        title: 'Test Title',
        body: 'Test Body',
        imageUrl: 'https://example.com/img.jpg',
        data: {'test': 'data'},
        receivedAt: DateTime(2024, 1, 15, 10, 30),
        type: PushNotificationType.medicationReminder,
      );

      final map = notification.toMap();

      expect(map['id'], 'test-id-456');
      expect(map['title'], 'Test Title');
      expect(map['body'], 'Test Body');
      expect(map['imageUrl'], 'https://example.com/img.jpg');
      expect(map['data'], {'test': 'data'});
      expect(map['type'], 'medicationReminder');
      expect(map['receivedAt'], isNotNull);
    });

    test('handles null values in map', () {
      final map = <String, dynamic>{
        'id': null,
        'title': null,
        'body': null,
      };

      final notification = PushNotification.fromMap(map);

      expect(notification.id, '');
      expect(notification.title, '');
      expect(notification.body, '');
      expect(notification.imageUrl, isNull);
      expect(notification.data, isNull);
      expect(notification.type, PushNotificationType.general);
    });

    group('PushNotificationType parsing', () {
      test('parses appointment_reminder correctly', () {
        final map = {'type': 'appointment_reminder'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.appointmentReminder);
      });

      test('parses appointment_confirmation correctly', () {
        final map = {'type': 'appointment_confirmation'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.appointmentConfirmation);
      });

      test('parses appointment_cancellation correctly', () {
        final map = {'type': 'appointment_cancellation'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.appointmentCancellation);
      });

      test('parses new_message correctly', () {
        final map = {'type': 'new_message'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.newMessage);
      });

      test('parses prescription_ready correctly', () {
        final map = {'type': 'prescription_ready'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.prescriptionReady);
      });

      test('parses health_tip correctly', () {
        final map = {'type': 'health_tip'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.healthTip);
      });

      test('parses medication_reminder correctly', () {
        final map = {'type': 'medication_reminder'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.medicationReminder);
      });

      test('defaults to general for unknown type', () {
        final map = {'type': 'unknown_type'};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.general);
      });

      test('defaults to general for null type', () {
        final map = <String, dynamic>{'type': null};
        final notification = PushNotification.fromMap(map);
        expect(notification.type, PushNotificationType.general);
      });
    });

    group('Navigation route', () {
      test('appointmentReminder returns appointment history route', () {
        final notification = PushNotification(
          id: '1',
          title: 'Test',
          body: 'Test',
          receivedAt: DateTime.now(),
          type: PushNotificationType.appointmentReminder,
        );
        expect(notification.getNavigationRoute(), '/patient/appointment-history');
      });

      test('appointmentConfirmation returns appointment history route', () {
        final notification = PushNotification(
          id: '1',
          title: 'Test',
          body: 'Test',
          receivedAt: DateTime.now(),
          type: PushNotificationType.appointmentConfirmation,
        );
        expect(notification.getNavigationRoute(), '/patient/appointment-history');
      });

      test('newMessage returns support route', () {
        final notification = PushNotification(
          id: '1',
          title: 'Test',
          body: 'Test',
          receivedAt: DateTime.now(),
          type: PushNotificationType.newMessage,
        );
        expect(notification.getNavigationRoute(), '/support');
      });

      test('prescriptionReady returns medical records route', () {
        final notification = PushNotification(
          id: '1',
          title: 'Test',
          body: 'Test',
          receivedAt: DateTime.now(),
          type: PushNotificationType.prescriptionReady,
        );
        expect(notification.getNavigationRoute(), '/patient/medical-records');
      });

      test('healthTip returns health tracker dashboard route', () {
        final notification = PushNotification(
          id: '1',
          title: 'Test',
          body: 'Test',
          receivedAt: DateTime.now(),
          type: PushNotificationType.healthTip,
        );
        expect(notification.getNavigationRoute(), '/patient/health-tracker-dashboard');
      });

      test('medicationReminder returns medication reminder setup route', () {
        final notification = PushNotification(
          id: '1',
          title: 'Test',
          body: 'Test',
          receivedAt: DateTime.now(),
          type: PushNotificationType.medicationReminder,
        );
        expect(notification.getNavigationRoute(), '/patient/medication-reminder-setup');
      });

      test('general returns null', () {
        final notification = PushNotification(
          id: '1',
          title: 'Test',
          body: 'Test',
          receivedAt: DateTime.now(),
          type: PushNotificationType.general,
        );
        expect(notification.getNavigationRoute(), isNull);
      });
    });

    test('toString returns expected format', () {
      final notification = PushNotification(
        id: 'id-1',
        title: 'My Title',
        body: 'My Body',
        receivedAt: DateTime.now(),
        type: PushNotificationType.general,
      );

      final str = notification.toString();

      expect(str, contains('id: id-1'));
      expect(str, contains('title: My Title'));
      expect(str, contains('body: My Body'));
      expect(str, contains('type: PushNotificationType.general'));
    });
  });
}
