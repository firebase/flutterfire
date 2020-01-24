// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('$CloudFunctions', () {
    testWidgets('call', (_) async {
      // default timeout
      final HttpsCallable callable =
          CloudFunctions.instance.getHttpsCallable(functionName: 'repeat');
      final HttpsCallableResult response =
          await callable.call(<String, dynamic>{
        'message': 'foo',
        'count': 1,
      });
      expect(response.data['repeat_message'], 'foo');

      // long custom timeout
      callable.timeout = const Duration(days: 300);
      expect(response.data['repeat_count'], 2);
      final dynamic response2 = await callable.call(<String, dynamic>{
        'message': 'bar',
        'count': 42,
      });
      expect(response2.data['repeat_message'], 'bar');
      expect(response2.data['repeat_count'], 43);
    });
  });
}
