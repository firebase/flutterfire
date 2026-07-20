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

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_ai_headers_e2e_test.dart' as headers_tests;
import 'firebase_ai_response_parsing_e2e_test.dart' as parsing_tests;
import 'firebase_ai_mock_test.dart' as mock_tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_ai', () {
    headers_tests.main();
    parsing_tests.main();
    mock_tests.main();
  });
}
