// ignore_for_file: public_member_api_docs, avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS('firebase')
library firebase.firebase_interop;

import 'package:js/js.dart';

import 'app_interop.dart';
import 'database_interop.dart';

@JS()
external DatabaseJsImpl database([AppJsImpl app]);

@JS()
external AppJsImpl app([String name]);
