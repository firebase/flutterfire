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

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes supported MIME types by media category', () {
    expect(
      FirebaseAIMimeTypes.image,
      const <String>['image/png', 'image/jpeg', 'image/webp'],
    );
    expect(
      FirebaseAIMimeTypes.document,
      const <String>['application/pdf', 'text/plain'],
    );
    expect(
      FirebaseAIMimeTypes.all,
      containsAll(<String>[
        ...FirebaseAIMimeTypes.image,
        ...FirebaseAIMimeTypes.video,
        ...FirebaseAIMimeTypes.audio,
        ...FirebaseAIMimeTypes.document,
      ]),
    );
  });
}
