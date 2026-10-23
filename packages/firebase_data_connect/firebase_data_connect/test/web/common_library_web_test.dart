// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('browser')
library;

import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogApiClient', () {
    test('should report web as the platform if using core sdk', () {
      const packageVersion = '1.0.0';
      expect(
        getGoogApiVal(CallerSDKType.core, packageVersion),
        'gl-dart/$packageVersion fire/$packageVersion gl-web',
      );
    });
    test('should report web as the platform if using gen sdk', () {
      const packageVersion = '1.0.0';
      expect(
        getGoogApiVal(CallerSDKType.generated, packageVersion),
        'gl-dart/$packageVersion fire/$packageVersion dart/gen gl-web',
      );
    });
  });
}
