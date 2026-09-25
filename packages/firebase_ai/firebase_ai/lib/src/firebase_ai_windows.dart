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

// Flutter's Windows plugin entry point is a static `registerWith()`.
// ignore_for_file: avoid_classes_with_only_static_members

/// Dart plugin registrant for Windows.
///
/// Flutter calls [registerWith] because `firebase_ai` declares a Windows
/// `dartPluginClass`. There is no native plugin and no method channel:
/// Windows has no app identity to attach to Firebase AI Logic requests.
/// `getPlatformSecurityHeaders` returns an empty map on Windows.
class FirebaseAIWindows {
  /// Registers the Windows implementation.
  ///
  /// Windows requests carry no app-identity headers, so there is no method
  /// channel to install.
  static void registerWith() {}
}
