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

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

bool _registered = false;

/// Registers [libraryName] and [version] with the Firebase Web JS SDK.
void registerWebLibraryVersion(String libraryName, String version) {
  if (_registered) return;
  try {
    final firebaseCore =
        globalContext.getProperty('firebase_core'.toJS) as JSObject?;
    if (firebaseCore != null &&
        firebaseCore.hasProperty('registerVersion'.toJS).toDart) {
      final sessionStorage =
          globalContext.getProperty('sessionStorage'.toJS) as JSObject?;
      final sessionKey = 'flutterfire-$libraryName-$version'.toJS;
      final existing =
          sessionStorage?.callMethod<JSAny?>('getItem'.toJS, sessionKey);
      if (existing == null) {
        sessionStorage?.callMethod<JSAny?>(
          'setItem'.toJS,
          sessionKey,
          version.toJS,
        );
        firebaseCore.callMethod<JSAny?>(
          'registerVersion'.toJS,
          libraryName.toJS,
          version.toJS,
        );
      }
      _registered = true;
    }
  } catch (_) {
    // Ignore when running in unit test environments without firebase_core JS.
  }
}
