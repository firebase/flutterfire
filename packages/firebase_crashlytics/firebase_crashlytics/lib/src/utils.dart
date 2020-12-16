// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:stack_trace/stack_trace.dart';

final _obfuscatedStackTraceLineRegExp =
    RegExp(r'^\s*#\d{2} abs [\da-f]+ virt [\da-f]+ .*$');

/// Returns a [List] containing detailed output of each line in a stack trace.
List<Map<String, String>> getStackTraceElements(StackTrace stackTrace) {
  final Trace trace = Trace.from(stackTrace).terse;
  final List<Map<String, String>> elements = <Map<String, String>>[];

  for (Frame frame in trace.frames) {
    try {
      if (frame is UnparsedFrame) {
        if (_obfuscatedStackTraceLineRegExp.hasMatch(frame.member)) {
          elements.add(<String, String>{
            'file': null,
            'line': '0',
            'method': frame.member,
          });
        }
      } else {
        final Map<String, String> element = <String, String>{
          'file': frame.library,
          'line': frame.line?.toString() ?? '0',
        };
        final List<String> members = frame.member.split('.');
        if (members.length > 1) {
          element['method'] = members.sublist(1).join('.');
          element['class'] = members.first;
        } else {
          element['method'] = frame.member;
        }
        elements.add(element);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  return elements;
}
