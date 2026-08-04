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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Method channel for the native platform helper plugin.
@visibleForTesting
const platformHeaderChannel = MethodChannel('plugins.flutter.io/firebase_ai');

Map<String, String>? _cachedHeaders;

/// Clears the cached platform headers. Only for use in tests.
@visibleForTesting
void clearPlatformSecurityHeadersCache() {
  _cachedHeaders = null;
}

/// Returns platform-specific security headers for API key restrictions.
///
/// Each platform's native plugin returns the appropriate headers:
/// - **Android**: `X-Android-Package` and `X-Android-Cert`
/// - **iOS/macOS**: `x-ios-bundle-identifier`
/// - **Web/other**: empty map (no plugin registered)
///
/// Results are cached since platform identity does not change at runtime.
Future<Map<String, String>> getPlatformSecurityHeaders() async {
  if (kIsWeb) return const {};
  if (_cachedHeaders != null) return _cachedHeaders!;

  try {
    final result = await platformHeaderChannel
        .invokeMapMethod<String, String>('getPlatformHeaders');
    _cachedHeaders = result ?? const {};
  } catch (_) {
    _cachedHeaders = const {};
  }
  return _cachedHeaders!;
}
