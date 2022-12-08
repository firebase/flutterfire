// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firestore_list_view_test.dart' as firestore_list_view_test;
import 'firestore_query_builder_test.dart' as firestore_query_builder_test;

import 'utils.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(prepare);

  firestore_list_view_test.main();
  firestore_query_builder_test.main();
}
