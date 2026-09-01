// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
      writeResponseOnFailure: true,
      responseDataCallback: (Map<String, dynamic>? data) async {
        final results =
            (data?['testResults'] as Map?)?.cast<String, dynamic>() ??
                const <String, dynamic>{};
        var passed = 0;
        var failed = 0;
        for (final entry in results.entries) {
          final ok = entry.value == 'success';
          ok ? passed++ : failed++;
          // ignore: avoid_print
          print('${ok ? '✅' : '❌'} ${entry.key}');
        }
        // ignore: avoid_print
        print('Web e2e summary: $passed passed, $failed failed, '
            '${results.length} total');
        if (results.isEmpty) {
          // ignore: avoid_print
          print('[E] No tests reported by the app - treating as '
              'infrastructure failure.');
          exit(1);
        }
        await writeResponseData(data);
      },
    );
