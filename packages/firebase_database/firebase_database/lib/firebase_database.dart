// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_database;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePluginPlatform;
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

export 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart'
    show ServerValue, TransactionHandler, DatabaseEventType, Transaction;

part 'src/data_snapshot.dart';

part 'src/database_event.dart';

part 'src/database_reference.dart';

part 'src/firebase_database.dart';

part 'src/on_disconnect.dart';

part 'src/query.dart';

part 'src/transaction_result.dart';
