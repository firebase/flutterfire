// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Returns a [List] containing detailed output of each line in a stack trace.
List<Map<String, String>> getStackTraceElements(List<String> lines) {
  final List<Map<String, String>> elements = <Map<String, String>>[];

  for (final String line in lines) {
    final List<String> lineParts = line.split(RegExp(r'\s+'));

    final String fileName = lineParts.first;

    // Sometimes the trace looks like [<file>,<methodField>] and doesn't contain a line field
    final String lineNumber =
        lineParts.length > 2 ? lineParts[1].split(':').first : '0';

    final Map<String, String> element = <String, String>{
      'file': fileName,
      'line': lineNumber,
    };

    final List<String> methodField = lineParts.last.split('.');

    final String methodName = methodField.last.trim();
    element['method'] = methodName;

    if (methodField.length > 1) {
      final String className = methodField.first.trim();
      element['class'] = className;
    }

    elements.add(element);
  }

  return elements;
}
