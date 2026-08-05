// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/common.dart' show Failure;
import 'package:integration_test/integration_test.dart';

/// Copies per-test results into [IntegrationTestWidgetsFlutterBinding.reportData]
/// so the web driver can print them; on web nothing else crosses the wire.
void reportTestResultsToDriver(IntegrationTestWidgetsFlutterBinding binding) {
  tearDownAll(() {
    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['testResults'] = <String, String>{
      for (final entry in binding.results.entries)
        entry.key: entry.value is Failure ? 'failed' : 'success',
    };
  });
}
