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

/// Parses a protobuf JSON duration, such as `2.520s`, into a [Duration].
///
/// Returns null when [value] is not a finite number of seconds ending in `s`,
/// or when that value does not fit in a [Duration].
Duration? parseProtoDuration(String value) {
  final trimmed = value.trim();
  if (!trimmed.endsWith('s')) {
    return null;
  }
  final seconds = double.tryParse(trimmed.substring(0, trimmed.length - 1));
  if (seconds == null || !seconds.isFinite) {
    return null;
  }
  final microseconds = seconds * 1000000;
  if (!microseconds.isFinite) {
    return null;
  }
  return Duration(microseconds: microseconds.round());
}
