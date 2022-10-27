// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_app_check;

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

export 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart'
    show AndroidProvider;
export 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;

part 'src/firebase_app_check.dart';
