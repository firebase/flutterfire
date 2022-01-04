// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS('firebase')
library firebase_interop.firebase;

import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'package:js/js.dart';
import 'performance_interop.dart';

@JS()
external PerformanceJsImpl performance([AppJsImpl? app]);
