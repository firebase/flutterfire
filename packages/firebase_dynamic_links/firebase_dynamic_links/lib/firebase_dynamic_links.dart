// ignore_for_file: require_trailing_commas
// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_dynamic_links;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;

part 'src/dynamic_link_builder.dart';
part 'src/firebase_dynamic_links.dart';
