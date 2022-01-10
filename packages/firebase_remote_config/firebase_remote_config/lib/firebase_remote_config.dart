// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_remote_config;

import 'dart:async';

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:flutter/foundation.dart';

export 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart'
    show
        RemoteConfigSettings,
        ValueSource,
        RemoteConfigFetchStatus,
        RemoteConfigValue;

part 'src/firebase_remote_config.dart';
