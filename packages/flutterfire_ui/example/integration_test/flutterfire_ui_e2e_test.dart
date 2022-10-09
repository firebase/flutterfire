// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'firestore_list_view_test.dart' as firestore_list_view;
import 'firestore_query_builder_test.dart' as firestore_query_builder;
import 'utils.dart';

void main() {
  setUpAll(setupEmulator);

  firestore_query_builder.main();
  firestore_list_view.main();
}
