// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

@JS('firebase.app')
library firebase_interop.core.app;

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_database_web/src/interop/database_interop.dart';
import 'package:js/js.dart';

@JS('App')
abstract class AppJsImpl extends core_interop.AppJsImpl {
  external DatabaseJsImpl database(String? databaseURL);
}
