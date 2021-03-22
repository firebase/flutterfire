import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic>? mockMessageMap;

  group('RemoteMessage: handle optional fields under sound null safety:', () {
    setUp(() {
      // basic message received, optional fields missing
      mockMessageMap = {
        'token': '012345678...',
        'data': {
          'via': 'FlutterFire Cloud Messaging!!!',
          'count': 1,
        },
        'notification': {
          'title': 'Hello FlutterFire!',
          'body': 'This notification was created from unit tests!',
        },
      };
    });

    test('Optional fields should be set false if absent', () {
      final message = RemoteMessage.fromMap(mockMessageMap!);

      expect(message.data, mockMessageMap!['data']);
      expect(message.notification, isA<RemoteNotification>());

      expect(message.mutableContent, false);
      expect(message.contentAvailable, false);
    });

    test('Optional fields should be set to given value if present', () {
      // add values for optional fields
      mockMessageMap!['mutableContent'] = true;
      mockMessageMap!['contentAvailable'] = true;

      final message = RemoteMessage.fromMap(mockMessageMap!);

      expect(message.data, mockMessageMap!['data']);
      expect(message.notification, isA<RemoteNotification>());

      expect(message.mutableContent, true);
      expect(message.contentAvailable, true);
    });
  });
}
