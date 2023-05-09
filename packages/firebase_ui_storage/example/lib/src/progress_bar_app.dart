// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/material.dart';

import 'apps.dart';

class ProgressBarApp extends StatefulWidget implements App {
  const ProgressBarApp({super.key});

  @override
  String get name => 'PrgressBar';

  @override
  State<StatefulWidget> createState() {
    return _ProgressBarAppState();
  }
}

class MockSnapshot implements TaskSnapshot {
  @override
  final int bytesTransferred;
  @override
  final int totalBytes;

  MockSnapshot({
    required this.bytesTransferred,
    required this.totalBytes,
  });

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class MockTask implements Task {
  final ctrl = StreamController<TaskSnapshot>();

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  @override
  Stream<TaskSnapshot> get snapshotEvents => ctrl.stream;
}

class _ProgressBarAppState extends State<ProgressBarApp> {
  final task = MockTask();

  @override
  void initState() {
    super.initState();
    emitProgress();
  }

  Future<void> emitProgress() async {
    for (var i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      task.ctrl.add(MockSnapshot(
        bytesTransferred: i * 10,
        totalBytes: 100,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TaskProgressIndicator(task: task);
  }
}
