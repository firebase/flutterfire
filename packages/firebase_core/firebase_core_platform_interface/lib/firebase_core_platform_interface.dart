// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The platform interface for Firebase Core.
library;

import 'dart:async';

import 'package:firebase_core_common/firebase_core_common.dart';
import 'package:firebase_core_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The parts of the platform interface which do not depend on Flutter live in
/// `firebase_core_common`, so that they can be consumed outside of Flutter.
/// They are imported by this library (so that the parts below can use them)
/// and re-exported, to keep this package the single entry point for Flutter
/// users.
export 'package:firebase_core_common/firebase_core_common.dart';

part 'src/method_channel/method_channel_firebase.dart';
part 'src/method_channel/method_channel_firebase_app.dart';
