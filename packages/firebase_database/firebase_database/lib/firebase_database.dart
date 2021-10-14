// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_database;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart'
    show
        ServerValue,
        MutableData,
        TransactionHandler,
        EventType,
        FirebaseDatabaseException;

part 'src/database_reference.dart';
part 'src/event.dart';
part 'src/firebase_database.dart';
part 'src/on_disconnect.dart';
part 'src/query.dart';
