// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_analytics;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:flutter/widgets.dart';

part 'src/firebase_analytics.dart';
