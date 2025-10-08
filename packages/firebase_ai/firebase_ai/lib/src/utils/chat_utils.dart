// Copyright 2025 Google LLC
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

import '../content.dart';

/// Aggregates a list of [Content] responses into a single [Content].
///
/// Includes all the [Content.parts] of every element of [contents],
/// and concatenates adjacent [TextPart]s into a single [TextPart],
/// even across adjacent [Content]s.
Content historyAggregate(List<Content> contents) {
  assert(contents.isNotEmpty);
  final role = contents.first.role ?? 'model';
  final textBuffer = StringBuffer();
  // If non-null, only a single text part has been seen.
  TextPart? previousText;
  final parts = <Part>[];
  void addBufferedText() {
    if (textBuffer.isEmpty) return;
    if (previousText case final singleText?) {
      parts.add(singleText);
      previousText = null;
    } else {
      parts.add(TextPart(textBuffer.toString()));
    }
    textBuffer.clear();
  }

  for (final content in contents) {
    for (final part in content.parts) {
      if (part case TextPart(:final text)) {
        if (text.isNotEmpty) {
          previousText = textBuffer.isEmpty ? part : null;
          textBuffer.write(text);
        }
      } else {
        addBufferedText();
        parts.add(part);
      }
    }
  }
  addBufferedText();
  return Content(role, parts);
}
