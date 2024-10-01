// Copyright 2024, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library firebase_data_connect_grpc;

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grpc/grpc.dart';

import '../common/common_library.dart';
import '../dataconnect_version.dart';
import '../generated/connector_service.pbgrpc.dart';
import '../generated/google/protobuf/struct.pb.dart';

part 'grpc_transport.dart';
