// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library firebase_ml_model_downloader;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart';
import 'package:flutter/foundation.dart';

export 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart'
    show
        FirebaseCustomModel,
        FirebaseModelDownloadType,
        FirebaseModelDownloadConditions;

part 'src/firebase_ml_model_downloader.dart';
