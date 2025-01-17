// ignore_for_file: require_trailing_commas
// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
// TODO(Lyokone): remove once we bump Flutter SDK min version to 3.3
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:flutter/foundation.dart';

export 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart'
    show HttpsCallableOptions, FirebaseFunctionsException;

part 'src/firebase_functions.dart';
part 'src/https_callable.dart';
part 'src/https_callable_result.dart';
