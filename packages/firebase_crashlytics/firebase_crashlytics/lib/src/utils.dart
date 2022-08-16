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
        // sessions, so same error can create different issues in Console.
        // We replace abs address with '0' so that Crashlytics Console can
        // group same exceptions. Also we don't need abs addresses for
        // deobfuscating, if we have virt address or symbol name + offset.
        final String method = frame.member.replaceFirstMapped(
            _obfuscatedStackTraceLineRegExp,
            (match) => '${match.group(1)}0${match.group(3)}');
        elements.add(<String, String>{
          'file': '',
          'line': '0',
          'method': method,
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
