// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// CI's `test:browser` step only runs `test/web`, in Chrome compiled to JS and
// to Wasm, so this file runs the whole unit suite there. On the VM, the tests
// run from their own files instead.
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import '../codec_test.dart' as codec;
import '../errors_test.dart' as errors;
import '../firebase_context_test.dart' as firebase_context;
import '../firebase_functions_test.dart' as firebase_functions;
import '../url_test.dart' as url;

void main() {
  group('codec', codec.main);
  group('errors', errors.main);
  group('firebase_context', firebase_context.main);
  group('firebase_functions', firebase_functions.main);
  group('url', url.main);
}

