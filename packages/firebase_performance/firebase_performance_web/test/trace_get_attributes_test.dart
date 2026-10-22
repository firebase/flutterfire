import 'dart:js_interop';

import 'package:firebase_performance_web/src/interop/performance.dart';
import 'package:firebase_performance_web/src/interop/performance_interop.dart'
    as performance_interop;
import 'package:flutter_test/flutter_test.dart';

@JS('eval')
external JSAny _eval(String code);

void main() {
  group('Trace', () {
    test('getAttributes returns a Map<String, String>', () {
      final jsTrace = _eval('''
        ({
          getAttributes: function() {
            return {
              "a": "b",
              "c": "d"
            };
          }
        })
      ''') as performance_interop.TraceJsImpl;

      final trace = Trace.fromJsObject(jsTrace);
      final attrs = trace.getAttributes();

      expect(attrs, isA<Map<String, String>>());
      expect(attrs, equals({'a': 'b', 'c': 'd'}));
    });

    test('getAttributes handles empty maps safely', () {
      final jsTrace = _eval('''
        ({
          getAttributes: function() {
            return {};
          }
        })
      ''') as performance_interop.TraceJsImpl;

      final trace = Trace.fromJsObject(jsTrace);
      final attrs = trace.getAttributes();

      expect(attrs, isA<Map<String, String>>());
      expect(attrs, isEmpty);
    });
  });
}
