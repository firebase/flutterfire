// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_storage;

import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'dart:io' show File;
import 'dart:convert' show utf8, base64;
import 'package:quiver/core.dart';

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'src/utils.dart';

export 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart'
    show
        ListOptions,
        FullMetadata,
        SettableMetadata,
        PutStringFormat,
        TaskState;

export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;

part 'src/firebase_storage.dart';
part 'src/reference.dart';
part 'src/list_result.dart';
part 'src/task.dart';
part 'src/task_snapshot.dart';
