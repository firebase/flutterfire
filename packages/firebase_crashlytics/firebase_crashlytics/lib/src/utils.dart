// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:stack_trace/stack_trace.dart';

final _obfuscatedStackTraceLineRegExp =
    RegExp(r'^(\s*#\d{2} abs )([\da-f]+)((?: virt [\da-f]+)?(?: .*)?)$');

/// Returns a [List] containing detailed output of each line in a stack trace.
List<Map<String, String>> getStackTraceElements(StackTrace stackTrace) {
  final Trace trace = Trace.parseVM(stackTrace.toString()).terse;
  final List<Map<String, String>> elements = <Map<String, String>>[];

  for (final Frame frame in trace.frames) {
    if (frame is UnparsedFrame) {
      if (_obfuscatedStackTraceLineRegExp.hasMatch(frame.member)) {
        // Same exceptions should be grouped in Crashlytics Console.
        // Crashlytics Console groups issues with same stack trace.
        // Obfuscated stack traces contains abs address, virt address
        // and symbol name + offset. abs addresses are different across
        // sessions, Crashlytics is smart enough to group exceptions
        // in the same issue. For iOS we use abs address for symbolication
        // and for Android we use virt address.
        elements.add(<String, String>{
          'file': '',
          'line': '0',
          'method': frame.member,
        });
      }
    } else {
      final Map<String, String> element = <String, String>{
        'file': frame.library,
        'line': frame.line?.toString() ?? '0',
      };
      final String member = frame.member ?? '<fn>';
      final List<String> members = member.split('.');
      if (members.length > 1) {
        element['method'] = members.sublist(1).join('.');
        element['class'] = members.first;
      } else {
        element['method'] = member;
      }
      elements.add(element);
    }
  }

  return elements;
}

String? getBuildId(StackTrace stackTrace) {
  final Trace trace = Trace.parseVM(stackTrace.toString()).terse;

  for (final Frame frame in trace.frames) {
    if (frame is UnparsedFrame) {
      if (frame.member.startsWith("build_id: '") &&
          frame.member.endsWith("'")) {
        // format is: "build_id: '8deece9b0e5bf1aa541b5a91e171282e'"
        return frame.member.substring(11, frame.member.length - 1);
      }
    }
  }

  return null;
}

List<String> getLoadingUnits(StackTrace stackTrace) =>
    Trace.parseVM(stackTrace.toString())
        .terse
        .frames
        .whereType<UnparsedFrame>()
        .map((frame) => frame.member)
        .where((member) => member.startsWith('loading_unit: '))
        .toList();
