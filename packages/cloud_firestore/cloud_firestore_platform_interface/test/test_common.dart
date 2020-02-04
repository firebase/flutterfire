// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_firestore.dart';

typedef MethodCallCallback = dynamic Function(MethodCall methodCall);

const kCollectionId = "test";
const kDocumentId = "document";

void handleMethodCall(MethodCallCallback methodCallCallback) =>
    MethodChannelFirestore.channel.setMockMethodCallHandler((call) async {
      expect(
          call.arguments["app"], equals(FirestorePlatform.instance.app.name));
      expect(call.arguments["path"], equals("$kCollectionId/$kDocumentId"));
      return await methodCallCallback(call);
    });
