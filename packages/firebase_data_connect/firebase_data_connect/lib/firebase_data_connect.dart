// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library firebase_data_connect;

import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'src/common/common_library.dart';
import 'src/network/transport_library.dart'
    if (dart.library.io) 'src/network/grpc_library.dart'
    if (dart.library.html) 'src/network/rest_library.dart';

export 'src/common/common_library.dart';

part 'src/core/empty_serializer.dart';
part 'src/core/ref.dart';
part 'src/firebase_data_connect.dart';
part 'src/optional.dart';
part 'src/timestamp.dart';
part 'src/any_value.dart';
